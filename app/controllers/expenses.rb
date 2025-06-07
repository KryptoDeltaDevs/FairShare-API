# frozen_string_literal: true

require 'roda'
require_relative 'app'

module FairShare
  class Api < Roda
    route('expenses') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @expense_route = "#{@api_root}/expenses"

      routing.is do
        expenses = ExpensePolicy::AccountScope.new(@auth_account).viewable

        owed_to_others = GetOwed.owed_to_others(id: @auth_account.id,
                                                expense_splits: expenses[:expense_splits],
                                                payments_sent: expenses[:payments_sent])

        owed_by_others = GetOwed.owed_by_others(id: @auth_account.id, expenses: expenses[:expenses],
                                                payments_received: expenses[:payments_received])

        { data: { owed_to_others:, owed_by_others: } }.to_json
      rescue StandardError
        routing.halt 500, { message: 'API server error' }.to_json
      end
    end
  end
end
