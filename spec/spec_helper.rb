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

DATA = {
  accounts: YAML.safe_load_file('db/seeds/account_seeds.yml'),
  groups: YAML.safe_load_file('db/seeds/group_seeds.yml'),
  group_members: YAML.safe_load_file('db/seeds/group_member_seeds.yml')
}.freeze
