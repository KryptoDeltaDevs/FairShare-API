# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GroupMember Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each { |account_data| FairShare::Account.create(account_data) }

    @owner = FairShare::Account.all[0]
    @member = FairShare::Account.all[1]

    DATA[:groups].each do |group_data|
      account_id = @owner.id
      new_group = FairShare::Group.new(group_data)
      new_group.created_by = account_id
      new_group.save_changes

      FairShare::GroupMember.create(group_id: new_group.id, account_id: account_id, role: 'owner')
    end
  end

  describe 'Getting Group Members' do
    it 'HAPPY: should be able to get list of all group members' do
      group = FairShare::Group.first
      FairShare::GroupMember.create(group_id: group.id, account_id: @member.id, role: 'member')

      req_header = { 'X-User-ID' => @member.id }
      get "/api/v1/groups/#{group.id}/members", {}, req_header

      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result.size).must_equal DATA[:accounts].size
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
      @req_header = { 'CONTENT_TYPE' => 'application/json', 'X-User-ID' => @owner.id }
      @group = FairShare::Group.first
      @member_data = { group_id: @group.id, account_id: @member.id, role: 'member' }
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
