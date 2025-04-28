# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      uuid :id, primary_key: true

      String :name, null: false
      String :email, null: false, unique: true
      String :password_digest, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
