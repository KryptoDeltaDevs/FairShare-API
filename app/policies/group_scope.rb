# frozen_string_literal: true

module FairShare
  # Policy to determine an account access to a group
  class GroupPolicy
    # Scope of group policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_groups(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        all_groups(@current_account)
      end

      private

      def all_groups(account)
        account.member_groups
      end

      def all_group_members(group)
        group.members
      end
    end
  end
end
