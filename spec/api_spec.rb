# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/group'

def app
  FairShare::Api
end

DATA = YAML.safe_load_file(File.expand_path('../db/store/seeds/group_seeds.yml', __dir__))

describe 'Test FairShare Web API' do
  include Rack::Test::Methods

  before do
    Dir.glob("#{FairShare::STORE_DIR}/*.txt").each { |f| FileUtils.rm(f) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
    _(last_response['Content-Type']).must_include 'application/json'
  end

  describe 'Handle groups' do
    it 'HAPPY: should be able to get list of all groups' do
      FairShare::Group.new(DATA[0]).save
      FairShare::Group.new(DATA[1]).save

      get 'api/v1/group'
      result = JSON.parse last_response.body
      _(result['group_ids'].uniq.count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single group' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }

      post '/api/v1/group', DATA[1].to_json, req_header
      _(last_response.status).must_equal 201

      created = JSON.parse(last_response.body)
      id = created['id']

      get "/api/v1/group/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown group requested' do
      get '/api/v1/group/foobar'
      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new group' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/group', DATA[0].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
