# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Group API' do
  include Rack::Test::Methods

  def app
    FairShare::Api
  end

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all groups' do
    FairShare::Group.create(DATA[:group][0]).save_changes
    FairShare::Group.create(DATA[:group][1]).save_changes

    get 'api/v1/groups'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    existing_group = DATA[:group][1]
    FairShare::Group.create(existing_group).save_changes
    id = FairShare::Group.first.id

    get "/api/v1/groups/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_group['name']
    _(result['data']['attributes']['description']).must_equal existing_group['description']
  end

  it 'SAD: should return error if unknown group requested' do
    get '/api/v1/groups/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new group members' do
    existing_group = DATA[:group][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/groups', existing_group.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    group = FairShare::Group.first

    _(created['id']).must_equal group.id
    _(created['name']).must_equal existing_group['name']
    _(created['description']).must_equal existing_group['description']
  end
end
