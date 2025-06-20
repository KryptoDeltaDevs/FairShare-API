# frozen_string_literal: true

module FairShare
  # Update Group Info
  class UpdateGroup
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

    def self.call(auth:, update_data:, group_id:)
      raise ForbiddenError unless auth.scope.can_write?('groups')

      group = Group.first(id: group_id)
      raise NotFoundError if group.nil?

      raise ForbiddenError if auth.account.id != group.created_by

      group.update(update_data)
    end
  end
end
