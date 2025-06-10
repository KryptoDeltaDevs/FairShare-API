# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group Member Detail
  class GroupMember < Sequel::Model
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    set_allowed_columns :group_id, :account_id, :role, :can_add_expense

    many_to_one :account
    many_to_one :group

    ROLES = %w[owner admin member].freeze

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'group_member',
          attributes: {
            id:,
            group_id:,
            account_id:,
            role:,
            can_add_expense:,
            created_at:,
            updated_at:
          }
        }, options
      )
    end
  end
end
