# frozen_string_literal: true

module FairShare
  # Create a group for a given account
  class CreateGroup
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create a group'
      end
    end

    def self.call(auth:, group_data:)
      raise ForbiddenError unless auth.scope.can_write?('groups')

      new_group = auth.account.add_group(group_data)

      auth.account.add_group_member(
        group_id: new_group.id,
        account_id: auth.account.id,
        role: 'owner',
        can_add_expense: true
      )
    end
  end
end
