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
    plugin :multi_route

    route do |routing|
      response['Content-Type'] = 'application/json'

      HttpRequest.new(routing).secure? || routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      routing.root do
        { message: 'FairShareAPI up at /api/v1' }.to_json
      end

      routing.on 'api/v1' do
        @api_root = 'api/v1'
        routing.multi_route
      end
    end
  end
end
