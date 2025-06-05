# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Account Handling' do
  include Rack::Test::Methods

  before do
    header 'CONTENT_TYPE', 'application/json'
    wipe_database
  end

  describe 'Account information' do
    it 'HAPPY: should be able to get details of an account' do
      account_data = DATA[:accounts][0]
      account = FairShare::Account.create(account_data)

      header 'AUTHORIZATION', auth_header(account_data)
      get "/api/v1/accounts/#{account.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal account.id
      _(result['attributes']['name']).must_equal account.name
      _(result['attributes']['salt']).must_be_nil
      _(result['attributes']['password']).must_be_nil
      _(result['attributes']['password_hash']).must_be_nil
    end
  end

  describe 'Account Creation' do
    before do
      @req_header = { 'Content-Type' => 'application/json' }
      @account_data = DATA[:accounts][0]
    end

    it 'HAPPY: should be able to create new account' do
      post 'api/v1/accounts', @account_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']
      account = FairShare::Account.first

      _(created['attributes']['id']).must_equal account.id
      _(created['attributes']['name']).must_equal @account_data['name']
      _(created['attributes']['email']).must_equal @account_data['email']
      _(account.password?(@account_data['password'])).must_equal true
      _(account.password?('not_really_the_password')).must_equal false
    end

    it 'BAD: should not create account with illegal attributes' do
      bad_data = @account_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/accounts', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
