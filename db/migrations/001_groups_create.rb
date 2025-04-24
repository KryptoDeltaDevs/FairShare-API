# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      uuid :id, primary_key: true
      String :name_secure, null: false
      String :description_secure, text: true, null: false
      # foreign_key :created_by, :users, null: false, on_delete: :cascade
      Integer :created_by, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
