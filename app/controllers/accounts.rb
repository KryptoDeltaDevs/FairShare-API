# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  # Web controller for FairShare API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |account_id|
        # GET api/v1/accounts/[account_id]
        routing.get do
          account = Account.first(id: account_id)
          account ? account.to_json : raise('Account not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        new_data = HttpRequest.new(routing).body_data
        new_account = Account.new(new_data)

        raise('Could not save account') unless new_account.save_changes

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.id}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ALIGNMENT:: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
