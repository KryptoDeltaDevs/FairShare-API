# frozen_string_literal: true

module FairShare
  # Find account and check password
  class AuthenticateAccount
    # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        super
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:email]}"
      end
    end

    def self.call(credentials)
      account = Account.first(email: credentials[:email])
      raise unless account.password?(credentials[:password])

      AuthorizedAccount.new(account, AuthScope::FULL).to_h
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
