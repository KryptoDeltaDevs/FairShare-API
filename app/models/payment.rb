# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  class Payment < Sequel::Model
    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    many_to_one :group
    many_to_one :expense
    many_to_one :from_account, class: 'FairShare::Account', key: :from_account_id
    many_to_one :to_account, class: 'FairShare::Account', key: :to_account_id

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'payment',
          attributes: {
            id:,
            expense_id:,
            amount:,
            created_at:
          },
          include: {
            group:,
            expense:,
            from_account:,
            to_account:
          }
        }, options
      )
    end
  end
end
