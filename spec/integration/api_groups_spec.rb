# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Group Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting groups' do
    before do
      @account = FairShare::Account.create(DATA[:accounts][0])
    end
    it 'HAPPY: should be able to get list of all groups for a user' do
      DATA[:groups].each do |group_data|
        account_id = @account.id
        new_group = FairShare::Group.new(group_data)
        new_group.created_by = account_id
        new_group.save_changes
        FairShare::GroupMember.create(group_id: new_group.id, account_id: account_id, role: 'owner')
      end

      req_header = { 'X-User-ID' => @account.id }
      get 'api/v1/groups', {}, req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result.count).must_equal 4
    end

    it 'HAPPY: should be able to get details of a single group' do
      account_id = @account.id
      group = FairShare::Group.new(DATA[:groups][0])
      group.created_by = account_id
      group.save_changes
      FairShare::GroupMember.create(group_id: group.id, account_id: account_id, role: 'owner')

      req_header = { 'X-User-ID' => @account.id }
      get "/api/v1/groups/#{group.id}", {}, req_header
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal group.id
      _(result['data']['attributes']['name']).must_equal group.name
      _(result['data']['attributes']['description']).must_equal group.description
    end

    it 'SAD: should return error if unknown group requested' do
      header 'X-User-ID', '999'
      get '/api/v1/groups/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      header 'X-User-ID', '999'
      get '/api/v1/groups/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Groups' do
    before do
      @account = FairShare::Account.create(DATA[:accounts][0])
      @req_header = { 'CONTENT_TYPE' => 'application/json', 'X-User-ID' => @account.id }
      @group_data = DATA[:groups][0]
    end

    it 'HAPPY: should be able to create new group' do
      post 'api/v1/groups', @group_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      group = FairShare::Group.first

      _(created['id']).must_equal group.id
      _(created['name']).must_equal @group_data['name']
      _(created['description']).must_equal @group_data['description']
    end

    it 'SECURITY: should not create group with mass assignment' do
      bad_data = @group_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/groups', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
