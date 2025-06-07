# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative 'password'

module FairShare
  # Models a registered account
  class Account < Sequel::Model
    plugin :uuid, field: :id
    plugin :association_dependencies
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security

    set_allowed_columns :name, :email, :password

    one_to_many :groups, key: :created_by
    one_to_many :group_members
    many_to_many :member_groups, class: 'FairShare::Group', join_table: :group_members, left_key: :account_id,
                                 right_key: :group_id

    one_to_many :expenses, key: :payer_id # this account paid
    one_to_many :expense_splits # what this account owes
    many_to_many :split_expenses, class: 'FairShare::Expense', join_table: :expense_splits, left_key: :account_id,
                                  right_key: :expense_id # expense this account is part of

    one_to_many :payments_sent, class: 'FairShare::Payment', key: :from_account_id
    one_to_many :payments_received, class: 'FairShare::Payment',  key: :to_account_id

    add_association_dependencies groups: :destroy

    def self.create_github_account(gh_account)
      create(name: gh_account[:name], email: gh_account[:email])
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = FairShare::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'account',
          attributes: {
            id:,
            name:,
            email:,
            created_at:,
            updated_at:
          }
        }, options
      )
    end
  end
end
