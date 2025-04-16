# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:group_members) do
      primary_key :id
      foreign_key :group_id, :groups, null: false, on_delete: :cascade
      # foreign_key :user_id, :users, null: false, on_delete: :cascade
      Integer :user_id, null: false
      String :role, null: false, default: 'member' # enum: owner, admin, member
      DateTime :created_at
      DateTime :updated_at

      unique %i[group_id user_id]
    end
  end
end
