# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:group_members) do
      uuid :id, primary_key: true
      uuid :group_id, null: false
      foreign_key [:group_id], :groups, key: :id, on_delete: :cascade
      # foreign_key :user_id, :users, null: false, on_delete: :cascade
      Integer :user_id, null: false
      String :role, null: false, default: 'member' # enum: owner, admin, member
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[group_id user_id]
    end
  end
end
