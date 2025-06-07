# frozen_string_literal: true

module FairShare
  # Creating an expense and expense split
  class CreateExpense
    def self.call(group_id:, expense:, split_expense:) # rubocop:disable Metrics/MethodLength
      expense = Expense.create(
        group_id:,
        payer_id: expense[:payer_id],
        name: expense[:name],
        description: expense[:description],
        total_amount: expense[:total_amount]
      )

      split_expense.each do |split|
        ExpenseSplit.create(
          expense_id: expense.id,
          account_id: split[:member],
          amount_owed: expense[:total_amount] * split[:percentage]
        )
      end
    end
  end
end
