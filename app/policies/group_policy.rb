# frozen_string_literal: true

module FairShare
  # Policy to determine an account access to a group
  class GroupPolicy
    def initialize(account, group, auth_scope = nil)
      @account = account
      @group = group
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_member?)
    end

    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      can_write? && !account_is_owner?
    end

    def can_add_expense?
      can_write? && FairShare::GroupMember.first(account_id: @account.id, group_id: @group.id).can_add_expense
    end

    def can_add_members?
      can_write? && account_is_owner?
    end

    def can_remove_members?
      can_write? && account_is_owner?
    end

    def can_join_group?
      !(account_is_owner? || account_is_member?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_expense: can_add_expense?,
        can_add_members: can_add_members?,
        can_remove_members: can_remove_members?,
        can_join_group: can_join_group?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('groups') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('groups') : false
    end

    def account_is_owner?
      @group.owner == @account
    end

    def account_is_member?
      @group.members.include?(@account)
    end
  end
end
