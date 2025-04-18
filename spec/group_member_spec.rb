# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test GroupMember API' do
  include Rack::Test::Methods

  def app
    FairShare::Api
  end

  before do
    wipe_database
    @group = FairShare::Group.create(DATA[:group][0])
    @owner = FairShare::GroupMember.create(group_id: @group.id, user_id: 1, role: 'owner')
  end

  it 'HAPPY: should be able to get list of all group members' do
    DATA[:group_members].each do |member|
      FairShare::GroupMember.create(
        group_id: @group.id,
        user_id: member['user_id'],
        role: member['role']
      )
    end

    header 'X-User-Id', '1'
    get "/api/v1/groups/#{@group.id}/members"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result.size).must_equal DATA[:group_members].size + 1
  end

  it 'SAD: should block unauthorized user from viewing members' do
    header 'X-User-Id', '999'
    get "/api/v1/groups/#{@group.id}/members"
    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to add a member (non-owner not allowed)' do
    header 'X-User-Id', '1'
    member_data = { user_id: 2, role: 'member' }

    header 'CONTENT_TYPE', 'application/json'
    post "/api/v1/groups/#{@group.id}/members", member_data.to_json

    _(last_response.status).must_equal 201
    result = JSON.parse last_response.body
    _(result['message']).must_match(/saved/)
  end

  it 'SAD: should not allow assigning owner role via API' do
    header 'X-User-Id', '1'
    member_data = { user_id: 3, role: 'owner' }

    header 'CONTENT_TYPE', 'application/json'
    post "/api/v1/groups/#{@group.id}/members", member_data.to_json

    _(last_response.status).must_equal 500
    result = JSON.parse last_response.body
    _(result['message']).must_match(/Cannot assign owner/)
  end
end
