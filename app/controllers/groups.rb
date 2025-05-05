# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('groups') do |routing|
      @group_route = "#{@api_root}/groups"

      routing.on String do |group_id|
        routing.on 'members' do
          @group_member_route = "#{@api_root}/groups/#{group_id}/members"

          # GET api/v1/groups/[group_id]/members
          routing.get do
            account_id = routing.env['X-User-ID']

            group_member = GroupMember.where(group_id: group_id, account_id: account_id).first
            raise 'Not authorized to view group members' unless group_member

            members = GroupMember.where(group_id: group_id).all

            JSON.pretty_generate(members)
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # POST api/v1/groups/[group_id]/members
          routing.post do
            account_id = routing.env['X-User-ID']

            group_member = GroupMember.where(group_id: group_id, account_id: account_id).first

            raise 'Not authorized to add members' unless group_member && group_member.role == 'owner'

            new_data = HttpRequest.new(routing).body_data

            raise 'Cannot assign owner role' if new_data['role'] == 'owner'

            new_data['group_id'] = group_id

            new_group_member = GroupMember.new(new_data)

            raise 'Invalid group member' unless new_group_member.save_changes

            response.status = 201
            response['Location'] = "#{@group_member_route}/#{new_group_member.id}"
            { message: 'Group Member saved', data: new_group_member }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end
        end

        # GET api/v1/groups/[group_id]
        routing.get do
          account_id = routing.env['X-User-ID']
          group_member = GroupMember.where(account_id: account_id, group_id: group_id).first

          raise 'User not authorized to view this group' unless group_member

          group = Group.first(id: group_id)

          raise 'Group not found' unless group

          group.to_json
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end

        # DELETE api/v1/groups/[group_id]
        routing.delete do
          account_id = routing.env['X-User-ID']
          group_member = GroupMember.where(account_id: account_id, group_id: group_id).first

          raise 'User not authorized to view this group' unless group_member && group_member.role == 'owner'

          group = Group.first(id: group_id)

          raise 'Group not found' unless group && group.created_by == account_id

          GroupMember.where(group_id: group_id).each(&:destroy)
          group.destroy

          { message: 'Group and associated group member deleted successfully' }.to_json
        rescue StandardError => e
          routing.halt 403, { message: e.message }.to_json
        end
      end

      # GET api/v1/groups
      routing.get do
        account_id = routing.env['X-User-ID']
        groups = GroupMember.where(account_id: account_id).map(&:group)
        JSON.pretty_generate(groups)
      rescue StandardError
        routing.halt 404, { message: 'Could not find groups' }.to_json
      end

      # POST api/v1/groups
      routing.post do
        account_id = routing.env['X-User-ID']
        new_data = HttpRequest.new(routing).body_data
        new_group = Group.new(new_data)
        new_group.created_by = account_id

        raise('Could not save group') unless new_group.save_changes

        new_group_member = GroupMember.new(
          group_id: new_group.id,
          account_id: account_id,
          role: 'owner'
        )

        raise('Could not save group_member') unless new_group_member.save_changes

        response.status = 201
        response['Location'] = "#{@group_route}/#{new_group.id}"
        { message: 'Group saved', data: new_group }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        routing.halt 400, { message: e.message }.to_json
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
