# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GroupMember Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:groups].each do |group_data|
      user_id = 1
      new_group = FairShare::Group.new(group_data)
      new_group.created_by = user_id
      new_group.save_changes

      FairShare::GroupMember.create(group_id: new_group.id, user_id: user_id, role: 'owner')
    end
  end

  describe 'Getting Group Members' do
    it 'HAPPY: should be able to get list of all group members' do
      group = FairShare::Group.first
      DATA[:group_members].each do |data|
        data['group_id'] = group.id
        FairShare::GroupMember.create(data)
      end

      req_header = { 'X-User-ID' => '1' }
      get "/api/v1/groups/#{group.id}/members", {}, req_header

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result.size).must_equal DATA[:group_members].size + 1
    end

    it 'SAD: should block unauthorized user from viewing members' do
      group = FairShare::Group.first
      header 'X-User-Id', '999'
      get "/api/v1/groups/#{group.id}/members"
      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Group Members' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json', 'X-User-ID' => '1' }
      @group = FairShare::Group.first
      @member_data = DATA[:group_members][0]
    end

    it 'HAPPY: should be able to add a member (non-owner not allowed)' do
      post "/api/v1/groups/#{@group.id}/members", @member_data.to_json, @req_header

      _(last_response.status).must_equal 201
      result = JSON.parse last_response.body
      _(result['message']).must_match(/saved/)
    end

    it 'SECURITY: should not create group members with mass alignment' do
      bad_data = @member_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/groups/#{@group.id}/members", bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
