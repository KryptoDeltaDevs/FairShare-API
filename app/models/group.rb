# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group detail
  class Group < Sequel::Model
    one_to_many :group_members

    plugin :timestamps, update_on_create: true

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id:,
              name:,
              description:,
              created_by:,
              created_at:,
              updated_at:
            }
          }
        }, options
      )
    end
  end
end
