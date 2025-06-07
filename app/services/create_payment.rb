# frozen_string_literal: true

module FairShare
  # Wrong Expense Data
  class BadPayment < StandardError
    def message
      'Bad Request'
    end
  end

  # Creating payment
  class CreatePayment
    def self.call(group_id:, from_account_id:, data:)
      raise BadPayment if ExpenseSplit.first(expense_id: data[:expense_id], account_id: from_account_id,
                                             amount_owed: data[:amount].to_f).nil?

      Payment.create(
        expense_id: data[:expense_id],
        group_id:,
        from_account_id:,
        to_account_id: data[:payer_id],
        amount: data[:amount].to_f
      )
    end
  end
end
