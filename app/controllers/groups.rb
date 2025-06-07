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
              account = Account.first(email: data[:email])
              GroupMember.create(group_id:, account_id: account.id, role: 'member', can_add_expense: false)
              response.status = 201
              { message: 'A member added to a group' }.to_json
            rescue StandardError => e
              routing.halt 400, { message: e.message }.to_json
            end
          end
        end

        routing.on 'send_invitation' do
          # POST api/v1/groups/[group_id]/send_invitation
          routing.post do
            data = HttpRequest.new(routing).body_data

            routing.halt 409 if data[:target_email] == @auth_account.email

            group = GetGroupQuery.call(account: @auth_account, group_id:)

            routing.halt 403 unless group[:attributes][:created_by] == @auth_account.id

            SendInvitation.new(data, group[:attributes][:name], @auth_account.name).call

            response.status = 200

            { message: 'Invitation sent' }.to_json
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
          end
        end

        # GET api/v1/groups/[group_id]
        routing.get do
          group = GetGroupQuery.call(account: @auth_account, group_id:)

          { data: group }.to_json
        rescue GetGroupQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetGroupQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND GROUP ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/groups/[group_id]
        routing.put do
          update_data = HttpRequest.new(routing).body_data
          group = Group.first(id: group_id)

          routing.halt 404, { message: 'Group not found' }.to_json unless group

          group_member = GroupMember.where(group_id: group_id, account_id: @auth_account.id).first
          routing.halt 403, { message: 'Not authorized to update group' }.to_json unless group_member&.role == 'owner'
          allowed_fields = %i[name description]
          group.set_fields(update_data, allowed_fields, missing: :skip)

          if group.save_changes
            response.status = 200
            { message: 'Group updated successfully', data: group }.to_json
          else
            routing.halt 400, { message: 'Failed to update group' }.to_json
          end
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{update_data.keys}"
          routing.halt 400, { message: 'Illegal attributes in request' }.to_json
        rescue StandardError => e
          routing.halt 500, { message: "Server error: #{e.message}" }.to_json
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
        groups = GroupPolicy::AccountScope.new(@auth_account).viewable

        JSON.pretty_generate(groups)
      rescue StandardError
        routing.halt 404, { message: 'Could not find groups' }.to_json
      end

      # POST api/v1/groups
      routing.post do
        new_data = HttpRequest.new(routing).body_data
        new_group = Group.new(new_data)
        new_group.created_by = @auth_account.id

        raise('Could not save group') unless new_group.save_changes

        new_group_member = GroupMember.new(
          group_id: new_group.id,
          account_id: @auth_account.id,
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
