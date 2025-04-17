# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test GroupMember API' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:group].each do |group_data|
      FairShare::Group.create(group_data)
    end
  end

  it 'HAPPY: should be able to get list of all group members' do
    group = FairShare::Group.first
    DATA[:group_members].each do |member|
      group.add_group_member(member)
    end

    get "api/v1/groups/#{group.id}/members"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 3
  end

  it 'HAPPY: should be able to get details of a single group member' do
    member_data = DATA[:group_members][1]
    group = FairShare::Group.first

    member = group.add_group_member(member_data).save # rubocop:disable Sequel/SaveChanges

    get "/api/v1/groups/#{group.id}/members/#{member.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal member.id
    _(result['data']['attributes']['user_id']).must_equal member_data['user_id']
  end

  it 'SAD: should return error if unknown group member requested' do
    group = FairShare::Group.first
    get "/api/v1/groups/#{group.id}/members/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new group members' do
    group = FairShare::Group.first
    member_data = DATA[:group_members][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/groups/#{group.id}/members",
         member_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.headers['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    member = FairShare::GroupMember.first

    _(created['id']).must_equal member.id
    _(created['user_id']).must_equal member_data['user_id']
    _(created['role']).must_equal member_data['role']
  end
end
