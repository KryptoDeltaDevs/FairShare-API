# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:payments) do
      uuid :id, primary_key: true
      uuid :expense_id, null: false
      uuid :group_id, null: false
      uuid :from_account_id, null: false
      uuid :to_account_id, null: false
      foreign_key [:expense_id], :expenses, key: :id, on_delete: :cascade
      foreign_key [:group_id], :groups, key: :id, on_delete: :cascade
      foreign_key [:from_account_id], :accounts, key: :id, on_delete: :cascade
      foreign_key [:to_account_id], :accounts, key: :id, on_delete: :cascade
      BigDecimal :amount, size: [10, 2], null: false
      DateTime :created_at, null: false
    end
  end
end
