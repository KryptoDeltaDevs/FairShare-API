# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group Member Detail
  class GroupMember < Sequel::Model
    many_to_one :group

    plugin :timestamps, update_on_create: true

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'group_member',
            attributes: {
              id:,
              group_id:,
              user_id:,
              role:,
              created_at:,
              updated_at:
            }
          }
        }, options
      )
    end
  end
end
