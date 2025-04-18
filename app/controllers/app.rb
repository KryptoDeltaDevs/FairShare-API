# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

require_relative '../models/group'
require_relative '../models/group_member'

module FairShare
  # App Controller for FairShare API
  class Api < Roda
    plugin :halt
    plugin :all_verbs

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'FairShareAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'groups' do
          @group_route = "#{@api_root}/groups"

          routing.on String do |group_id|
            routing.on 'members' do
              @group_member_route = "#{@api_root}/groups/#{group_id}/members"

              # GET api/v1/groups/[group_id]/members
              routing.get do
                user_id = routing.env['HTTP_X_USER_ID'].to_i

                group_member = GroupMember.where(group_id: group_id, user_id: user_id).first
                raise 'Not authorized to view group members' unless group_member

                members = GroupMember.where(group_id: group_id).all

                JSON.pretty_generate(members)
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # POST api/v1/groups/[group_id]/members
              routing.post do
                user_id = routing.env['HTTP_X_USER_ID'].to_i

                group_member = GroupMember.where(group_id: group_id, user_id: user_id).first

                raise 'Not authorized to add members' unless group_member && group_member.role == 'owner'

                new_data = JSON.parse(routing.body.read)

                raise 'Cannot assign owner role' if new_data['role'] == 'owner'

                new_group_member = GroupMember.create(
                  group_id: group_id,
                  user_id: new_data['user_id'],
                  role: new_data['role'] || 'member'
                )

                raise 'Invalid group member' unless new_group_member.valid?

                response.status = 201
                response['Location'] = "#{@group_member_route}/#{new_group_member.id}"
                { message: 'Group Member saved', data: new_group_member }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/groups/[group_id]
            routing.get do
              user_id = routing.env['HTTP_X_USER_ID'].to_i
              group_member = GroupMember.where(user_id: user_id, group_id: group_id).first

              raise 'User not authorized to view this group' unless group_member

              group = Group.first(id: group_id)

              raise 'Group not found' unless group

              group.to_json
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end

            # DELETE api/v1/groups/[group_id]
            routing.delete do
              user_id = routing.env['HTTP_X_USER_ID'].to_i
              group_member = GroupMember.where(user_id: user_id, group_id: group_id).first

              raise 'User not authorized to view this group' unless group_member && group_member.role == 'owner'

              group = Group.first(id: group_id)

              raise 'Group not found' unless group && group.created_by == user_id

              GroupMember.where(group_id: group_id).each(&:destroy)
              group.destroy

              { message: 'Group and associated group member deleted successfully' }.to_json
            rescue StandardError => e
              routing.halt 403, { message: e.message }.to_json
            end
          end

          # GET api/v1/groups
          routing.get do
            user_id = routing.env['HTTP_X_USER_ID'].to_i
            groups = GroupMember.where(user_id: user_id).map(&:group)
            JSON.pretty_generate(groups)
          rescue StandardError
            routing.halt 404, { message: 'Could not find groups' }.to_json
          end

          # POST api/v1/groups
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_group = Group.create(
              name: new_data['name'],
              description: new_data['description'],
              created_by: new_data['created_by']
            )
            raise('Could not save group') unless new_group.valid?

            new_group_member = GroupMember.create(
              group_id: new_group.id,
              user_id: new_data['created_by'],
              role: 'owner'
            )
            raise('Could not save group_member') unless new_group_member.valid?

            response.status = 201
            response['Location'] = "#{@group_route}/#{new_group.id}"
            { message: 'Group saved', data: new_group }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
