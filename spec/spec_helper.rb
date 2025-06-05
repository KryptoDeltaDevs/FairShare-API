# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  FairShare::Account.map(&:destroy)
  FairShare::Group.map(&:destroy)
  FairShare::GroupMember.map(&:destroy)
end

def auth_header(account_data)
  auth = FairShare::AuthenticateAccount.call(
    email: account_data['email'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.safe_load_file('db/seeds/accounts_seed.yml'),
  groups: YAML.safe_load_file('db/seeds/groups_seed.yml')
}.freeze
