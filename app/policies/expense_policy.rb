# frozen_string_literal: true

module FairShare
  class ExpensePolicy
    def initialize(account, expense)
      @account = account
      @expense = expense
    end
  end
end
