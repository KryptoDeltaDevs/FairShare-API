# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('groups') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @group_route = "#{@api_root}/groups"

      routing.on String do |group_id|
        routing.on 'payments' do
          routing.is do
            # POST api/v1/groups/[group_id]/payments
            routing.post do
              data = HttpRequest.new(routing).body_data
              CreatePayment.call(group_id:, from_account_id: @auth_account.id, data:)
              response.status = 202
              { message: 'Payment Accepted' }.to_json
            rescue BadPayment => e
              routing.halt 400, { message: e.message }.to_json
            end
          end
        end

        routing.on 'expenses' do
          routing.is do
            # POST api/v1/groups/[group_id]/expenses
            routing.post do
              data = HttpRequest.new(routing).body_data
              CreateExpense.call(group_id:, expense: data[:expense], split_expense: data[:split_expense])
              response.status = 201
              { message: 'Expense created' }.to_json
            end
          end
        end

        routing.on 'members' do
          routing.is do
            # POST api/v1/groups/[group_id]/members
            routing.post do
              data = HttpRequest.new(routing).body_data
              AddMember.call(email: data[:email], group_id:)
              response.status = 201
              { message: 'A member added to a group' }.to_json
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end

            # PUT api/v1/groups/[group_id]/members
            routing.put do
              group_members = HttpRequest.new(routing).body_data
              UpdateAccess.call(group_members:, group_id:)
              response.status = 200
              { message: 'Update accesses' }.to_json
            end
          end
        end

        routing.on 'send_invitation' do
          # POST api/v1/groups/[group_id]/send_invitation
          routing.post do
            data = HttpRequest.new(routing).body_data

            routing.halt 409 if data[:target_email] == @auth_account.email

            group = GetGroupQuery.call(auth: @auth, group_id:)

            routing.halt 403 unless group[:attributes][:created_by] == @auth_account.id

            SendInvitation.new(data, group[:attributes][:name], @auth_account.name).call

            response.status = 200

            { message: 'Invitation sent' }.to_json
          rescue StandardError => e
            Api.logger.error "#{e.inspect}\n#{e.backtrace}"
          end
        end

        # GET api/v1/groups/[group_id]
        routing.get do
          group = GetGroupQuery.call(auth: @auth, group_id:)

          { data: group }.to_json
        rescue GetGroupQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetGroupQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "FIND GROUP ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/groups/[group_id]
        routing.put do
          update_data = HttpRequest.new(routing).body_data
          UpdateGroup.call(auth: @auth, update_data:, group_id:)
          response.status = 200
          { message: 'Updated successfully ' }.to_json
        rescue UpdateGroup::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue UpdateGroup::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{update_data.keys}"
          routing.halt 400, { message: 'Illegal attributes in request' }.to_json
        rescue StandardError => e
          routing.halt 500, { message: "Server error: #{e.message}" }.to_json
        end
      end

      # GET api/v1/groups
      routing.get do
        groups = GroupPolicy::AccountScope.new(@auth_account).viewable

        JSON.pretty_generate(groups)
      rescue StandardError
        routing.halt 404, { message: 'Could not find groups' }.to_json
      end

      # POST api/v1/groups
      routing.post do
        new_data = HttpRequest.new(routing).body_data
        new_group = CreateGroup.call(auth: @auth, group_data: new_data)

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
