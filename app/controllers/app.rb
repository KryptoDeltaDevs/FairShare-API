# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

require_relative '../models/group'

module FairShare
  # App Controller for FairShare API
  class Api < Roda
    plugin :halt

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

              # GET api/v1/groups/[group_id]/members/[member_id]
              routing.get String do |group_member_id|
                gm = GroupMember.where(group_id: group_id, id: group_member_id).first
                gm ? gm.to_json : raise('Group member not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/groups/[group_id]/members
              routing.get do
                output = { data: Group.first(id: group_id).group_members }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find group members'
              end

              # POST api/v1/groups/[group_id]/members
              routing.post do
                new_data = JSON.parse(routing.body.read)
                group = Group.first(id: group_id)
                new_gm = group.add_group_member(new_data)

                if new_gm
                  response.status = 201
                  response['Location'] = "#{@group_member_route}/#{new_gm.id}"
                  { message: 'Group member saved', data: new_gm }.to_json
                else
                  routing.halt 400, 'Could not save group member'
                end
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/groups/[group_id]
            routing.get do
              group = Group.first(id: group_id)
              group ? group.to_json : raise('Group not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/groups
          routing.get do
            output = { data: Group.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find groups' }.to_json
          end

          # POST api/v1/groups
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_group = Group.new(new_data)
            raise('Could not save group') unless new_group.save_changes

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
