# frozen_string_literal: true

module FairShare
  # Add a group member to an existing group
  class AddGroupMemberToGroup
    # Error if member is trying to become admin
    class AdminNotAssignableError < StandardError
      def message = 'Cannot assign admin role'
    end

    def self.call(account_id:, group_id:, role:)
      group = Group.first(id: group_id)
      raise AdminNotAssignableError if role == 'admin'

      account = Account.first(id: account_id)
      group.add_member(account, role)
    end
  end
end
