# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:group_members) do
      uuid :group_id, null: false
      uuid :account_id, null: false
      foreign_key [:group_id], :groups, key: :id, on_delete: :cascade
      foreign_key [:account_id], :accounts, key: :id, on_delete: :cascade
      String :role, null: false, default: 'member' # enum: owner, admin, member
      TrueClass :can_add_expense, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      primary_key [:group_id, :account_id]
    end
  end
end
