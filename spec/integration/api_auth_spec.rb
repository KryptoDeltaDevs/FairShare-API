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
      post 'api/v1/auth/authenticate',
           SignedRequest.sign(credentials).to_json,
           @req_header

      account = JSON.parse(last_response.body)['attributes']['account']['attributes']
      _(last_response.status).must_equal 200
      _(account['name']).must_equal(@account_data['name'])
      _(account['email']).must_equal(@account_data['email'])
    end

    it 'BAD: should not authenticate invalid password' do
      bad_credentials = { email: @account_data['email'],
                          password: 'fakepassword' }

      post 'api/v1/auth/authenticate',
            SignedRequest.sign(bad_credentials).to_json,
            @req_header

      result = JSON.parse(last_response.body)

      _(last_response.status).must_equal 403
      _(result['message']).wont_be_nil
      _(result['attributes']).must_be_nil
    end
  end

  describe 'SSO Authorization' do
    before do
      WebMock.enable!
      WebMock.stub_request(:get, app.config.GITHUB_ACCOUNT_URL)
             .to_return(body: GH_ACCOUNT_RESPONSE[GOOD_GH_ACCESS_TOKEN],
                        status: 200,
                        headers: { 'content-type' => 'application/json' })
    end

    after do
      WebMock.disable!
    end

    it 'HAPPY AUTH SSO: should authenticate+authorize new valid SSO account' do
      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }

      post 'api/v1/auth/sso',
           SignedRequest.sign(gh_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']['attributes']

      _(last_response.status).must_equal 200
      _(account['name']).must_equal(SSO_ACCOUNT['sso_name'])
      _(account['email']).must_equal(SSO_ACCOUNT['email'])
      _(account['id']).must_be_nil
    end

    it 'HAPPY AUTH SSO: should authorize existing SSO account' do
      Credence::Account.create(
        name: SSO_ACCOUNT['sso_name'],
        email: SSO_ACCOUNT['email']
      )

      gh_access_token = { access_token: GOOD_GH_ACCESS_TOKEN }
      post 'api/v1/auth/sso',
           SignedRequest.sign(gh_access_token).to_json,
           @req_header

      auth_account = JSON.parse(last_response.body)['data']
      account = auth_account['attributes']['account']['attributes']

      _(last_response.status).must_equal 200
      _(account['name']).must_equal(SSO_ACCOUNT['sso_name'])
      _(account['email']).must_equal(SSO_ACCOUNT['email'])
      _(account['id']).must_be_nil
    end
  end
end
