# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:groups].delete
  app.DB[:group_members].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:groups] = YAML.safe_load_file('db/seeds/group_seeds.yml')
DATA[:group_members] = YAML.safe_load_file('db/seeds/group_member_seeds.yml')
