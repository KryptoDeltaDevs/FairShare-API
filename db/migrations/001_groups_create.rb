# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      primary_key :id
      String :name, null: false
      String :description, null: false
      # foreign_key :created_by, :users, null: false, on_delete: :cascade
      Integer :created_by, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
