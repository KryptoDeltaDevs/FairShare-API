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

  it 'HAPPY: should be able to get list of all groups for a user' do
    group1 = FairShare::Group.create(DATA[:group][0])
    group2 = FairShare::Group.create(DATA[:group][0])

    FairShare::GroupMember.create(group_id: group1.id, user_id: 1, role: 'member')
    FairShare::GroupMember.create(group_id: group2.id, user_id: 1, role: 'member')

    header 'X-User-ID', '1'
    get 'api/v1/groups'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single group' do
    group = FairShare::Group.create(DATA[:group][1])
    FairShare::GroupMember.create(group_id: group.id, user_id: 1, role: 'member')

    header 'X-User-ID', '1'
    get "/api/v1/groups/#{group.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal group.id
    _(result['data']['attributes']['name']).must_equal group.name
  end

  it 'SAD: should return error if unknown group requested' do
    header 'X-User-ID', '999'
    get '/api/v1/groups/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new group members' do
    group_data = DATA[:group][0]

    header 'CONTENT_TYPE', 'application/json'
    post 'api/v1/groups', group_data.to_json

    _(last_response.status).must_equal 201
    result = JSON.parse(last_response.body)['data']

    _(result['data']['attributes']['name']).must_equal group_data['name']
  end
end
