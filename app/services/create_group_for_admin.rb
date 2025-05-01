# frozen_string_literal: true

module FairShare
  # Create a group for a given account
  class CreateGroupForAdmin
    def self.call(account_id:, group_data:)
      Account.find(id: account_id)
             .add_owned_group(group_data)
    end
  end
end
  