# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group Member Detail
  class GroupMember < Sequel::Model
    plugin :uuid, field: :id
    many_to_one :group

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :group_id, :user_id, :role

    ROLES = %w[owner admin member].freeze

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
