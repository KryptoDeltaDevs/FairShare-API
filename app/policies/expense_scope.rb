# frozen_string_literal: true

module FairShare
  class ExpensePolicy
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_expenses(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        { expenses: all_expenses(@current_account), expense_splits: all_expense_splits(@current_account),
          payments_received: all_payments_received(@current_account),
          payments_sent: all_payments_sent(@current_account) }
      end

      private

      def all_expenses(account)
        account.expenses
      end

      def all_expense_splits(account)
        account.expense_splits
      end

      def all_payments_received(account)
        account.payments_received
      end

      def all_payments_sent(account)
        account.payments_sent
      end
    end
  end
end
