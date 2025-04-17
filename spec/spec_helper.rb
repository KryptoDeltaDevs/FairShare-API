# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:group_members].delete
  app.DB[:groups].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:group_members] = YAML.safe_load_file('db/seeds/group_member_seeds.yml')
DATA[:group] = YAML.safe_load_file('db/seeds/group_seeds.yml')
