# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  class ExpenseSplit < Sequel::Model
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    set_allowed_columns :expense_id, :account_id, :amount_owed

    many_to_one :expense
    many_to_one :account

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'expense_split',
          attributes: {
            expense_id:,
            account_id:,
            amount_owed:,
            created_at:
          }
        }, options
      )
    end
  end
end
