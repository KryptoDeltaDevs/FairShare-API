# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:expenses) do
      uuid :id, primary_key: true
      String :name_secure, null: false
      String :description_secure, text: true, null: false
      uuid :group_id, null: false
      uuid :payer_id, null: false
      foreign_key [:group_id], :groups, key: :id, on_delete: :cascade
      foreign_key [:payer_id], :accounts, key: :id, on_delete: :cascade
      BigDecimal :total_amount, size: [10, 2], null: false
      DateTime :created_at, null: false
    end
  end
end
