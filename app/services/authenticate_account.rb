# frozen_string_literal: true

module FairShare
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

  # Find account and check password
  class AuthenticateAccount
    def self.call(credentials)
      account = Account.first(email: credentials[:email])
      account.password?(credentials[:password]) ? account : raise
    rescue StandardError
      raise UnauthorizedError, credentials
    end
  end
end
