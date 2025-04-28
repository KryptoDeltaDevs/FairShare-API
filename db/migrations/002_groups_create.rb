# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      uuid :id, primary_key: true
      String :name_secure, null: false
      String :description_secure, text: true, null: false
      uuid :created_by, null: false
      foreign_key [:created_by], :accounts, key: :id, on_delete: :cascade
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
