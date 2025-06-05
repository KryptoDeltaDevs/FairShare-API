# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  class Expense < Sequel::Model
    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    # plugin :whitelist_security

    many_to_one :group
    many_to_one :payer, class: 'FairShare::Account', key: :payer_id
    one_to_many :expense_splits
    one_to_many :payments

    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'expense',
          attributes: {
            id:,
            name:,
            description:,
            payer_id:,
            total_amount:,
            created_at:
          },
          include: {
            group:,
            payer:
          }
        }, options
      )
    end
  end
end
