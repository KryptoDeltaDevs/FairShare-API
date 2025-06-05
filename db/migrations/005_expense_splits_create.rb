# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:expense_splits) do
      uuid :expense_id, null: false
      uuid :account_id, null: false
      foreign_key [:expense_id], :expenses, key: :id, on_delete: :cascade
      foreign_key [:account_id], :accounts, key: :id, on_delete: :cascade
      BigDecimal :amount_owed, size: [10, 2], null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      primary_key [:expense_id, :account_id]
    end
  end
end
