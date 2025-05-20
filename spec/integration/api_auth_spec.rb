# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Authentication Routes' do
  include Rack::Test::Methods

  before do
    @req_header = { 'CONTENT_TYPE' => 'application/json' }
    wipe_database
  end

  describe 'Account Authentication' do
    before do
      @account_data = DATA[:accounts][0]
      @account = FairShare::Account.create(@account_data)
    end

    it 'HAPPY: should authenticate valid credentials' do
      credentials = { email: @account_data['email'], password: @account_data['password'] }
      post 'api/v1/auth/authenticate', credentials.to_json, @req_header

      account = JSON.parse(last_response.body)['attributes']['account']['attributes']
      _(last_response.status).must_equal 200
      _(account['name']).must_equal(@account_data['name'])
      _(account['email']).must_equal(@account_data['email'])
    end

    it 'BAD: should not authenticate invalid password' do
      credentials = { email: @account_data['email'],
                      password: 'fakepassword' }

      post 'api/v1/auth/authenticate', credentials.to_json, @req_header

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end
end
