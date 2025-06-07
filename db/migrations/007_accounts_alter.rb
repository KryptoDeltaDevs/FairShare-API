# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:accounts) do
      set_column_allow_null :password_digest
    end
  end
end
