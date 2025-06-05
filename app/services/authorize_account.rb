# frozen_string_literal: true

module FairShare
  # Authorize an account
  class AuthorizeAccount
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that account'
      end
    end

    def self.call(auth:, id:, auth_scope:)
      account = Account.first(id:)
      policy = AccountPolicy.new(auth.account, account)
      raise ForbiddenError unless policy.can_view?

      AuthorizedAccount.new(account, auth_scope)
    end
  end
end
