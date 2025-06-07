# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group detail
  class Group < Sequel::Model
    plugin :uuid, field: :id
    # plugin :association_dependencies
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    set_allowed_columns :name, :description

    many_to_one :owner, class: 'FairShare::Account', key: :created_by
    many_to_many :members, class: 'FairShare::Account', join_table: :group_members, left_key: :group_id,
                           right_key: :account_id
    one_to_many :group_members
    one_to_many :expenses
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

    def expense_splits
      expenses.flat_map(&:expense_splits)
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          members:,
          expenses:,
          payments:,
          expense_splits: expense_splits
        }
      )
    end

    def to_h # rubocop:disable Metrics/MethodLength
      {
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
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
