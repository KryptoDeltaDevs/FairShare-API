# frozen_string_literal: true

module FairShare
  class GetOwed
    def self.owed_to_others(id:, expense_splits:, payments_sent:)
      total_owed = expense_splits
                   .reject { |es| es.expense.payer_id == id }
                   .sum(&:amount_owed)

      total_paid = payments_sent.sum(&:amount)

      [total_owed - total_paid, 0].max.to_f
    end

    def self.owed_by_others(id:, expenses:, payments_received:)
      total_receiveable = expenses
                          .flat_map(&:expense_splits)
                          .reject { |es| es.account_id == id }
                          .sum(&:amount_owed)

      total_received = payments_received.sum(&:amount)

      [total_receiveable - total_received, 0].max.to_f
    end
  end
end
