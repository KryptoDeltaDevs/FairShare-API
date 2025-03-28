# frozen_string_literal: true

require 'roda'
require 'json'
require 'logger'

require_relative '../models/group'

module FairShare
  # App Controller for FairShare API
  class Api < Roda
    plugin :environments
    plugin :halt
    plugin :common_logger, $stderr

    configure do
      Group.setup
    end

    route do |r| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      r.root do
        response.status = 200
        { message: 'FairShareAPI up at /api/v1' }.to_json
      end

      r.on 'api' do
        r.on 'v1' do
          r.on 'group' do
            r.get String do |id|
              response.status = 200
              Group.find(id).to_json
            rescue StandardError
              r.halt 404, { message: 'Group not found' }.to_json
            end

            r.get do
              response.status = 200
              results = { group_ids: Group.all }
              JSON.pretty_generate(results)
            end

            r.post do
              new_data = JSON.parse(r.body.read)
              new_group = Group.new(new_data)

              if new_group.save
                response.status = 201
                { message: 'Group saved', id: new_group.id }.to_json
              else
                r.halt 400, { message: 'Could not save group' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
