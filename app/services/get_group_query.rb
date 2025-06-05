# frozen_string_literal: true

module FairShare
  # Get a single group
  class GetGroupQuery
    # Error if an account has no access to a group
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access the group'
      end
    end

    # Error if a group doesn't exist
    class NotFoundError < StandardError
      def message
        'Cannot find the group'
      end
    end

    def self.call(account:, group_id:)
      group = Group.first(id: group_id)
      raise NotFoundError unless group

      policy = GroupPolicy.new(account, group)
      raise ForbiddenError unless policy.can_view?

      group.full_details.merge(policies: policy.summary)
    end
  end
end
