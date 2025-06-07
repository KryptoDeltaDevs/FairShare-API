# frozen_string_literal: true

module FairShare
  # Add a group member to an existing group
  class AddMember
    # Error if member is trying to become owner
    class ForbiddenError < StandardError
      def message
        'You are not allowed to do that'
      end
    end

    # Cannot find resource
    class NotFoundError < StandardError
      def message
        'Cannot find what you were looking for'
      end
    end

    def self.call(email:, group_id:)
      account = Account.first(email:)

      raise NotFoundError if account.nil?

      group = Group.first(id: group_id)

      raise NotFoundError if group.nil?

      group.add_group_member(group_id:, account_id: account.id, role: 'member', can_add_expense: false)
    end
  end
end
