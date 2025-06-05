# frozen_string_literal: true

module FairShare
  # Get account by id
  class GetAccountQuery
    # Error if requesting to see forbidden content
    class ForbiddenError < StandardError
      def message
        "You're not allowed to access that project"
      end
    end

    def self.call(requestor:, id:)
      account = Account.first(id:)

      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
