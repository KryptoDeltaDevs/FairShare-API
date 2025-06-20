# frozen_string_literal: true

module FairShare
  # HTTP Request helper methods
  class HttpRequest
    def initialize(routing)
      @routing = routing
    end

    def secure?
      raise 'Secure scheme not configured' unless Api.config.SECURE_SCHEME

      @routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authorized_account
      return nil unless @routing.headers['AUTHORIZATION']

      scheme, auth_token = @routing.headers['AUTHORIZATION'].split
      return nil unless scheme.match?(/^Bearer$/i)

      payload = AuthToken.new(auth_token).payload
      account = Account.first(id: payload['attributes']['id'])
      token = AuthToken.new(auth_token)
      AuthorizedAccount.new(account, token.scope)
    end

    def body_data
      JSON.parse(@routing.body.read, symbolize_names: true)
    end

    def signed_body_data
      SignedRequest.parse(body_data)
    end
  end
end
