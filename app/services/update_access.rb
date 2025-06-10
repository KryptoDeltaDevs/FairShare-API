# frozen_string_literal: true

module FairShare
  # Update Member Access
  class UpdateAccess
    # No access to resource
    class ForbiddenError < StandardError
      def message
        'You are not allowed to modify this group'
      end
    end

    # Resource not exist
    class NotFoundError < StandardError
      def message
        'Cannot find the group'
      end
    end

    def self.call(group_members:, group_id:)
      group_members.each do |group_member|
        member = GroupMember.first(group_id:, account_id: group_member[:account_id])

        member.update(can_add_expense: !group_member[:can_add_expense])
      end
    end
  end
end
