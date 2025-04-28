# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GroupMember Handling' do
  before do
    wipe_database

    @account = FairShare::Account.create(DATA[:accounts][0])
    @member = FairShare::Account.create(DATA[:accounts][1])

    DATA[:groups].each do |group_data|
      group = FairShare::Group.new(group_data)
      group.created_by = @account.id
      group.save_changes
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    group = FairShare::Group.first
    member_data = { group_id: group.id, account_id: @member.id, role: 'member' }
    new_member = FairShare::GroupMember.create(member_data)

    member = FairShare::GroupMember.find(group_id: new_member.group_id, account_id: new_member.account_id)
    _(member.account_id).must_equal member_data[:account_id]
    _(member.role).must_equal member_data[:role]
  end

  it 'SECURITY: should not use deterministic integers' do
    member_data = { group_id: FairShare::Group.first.id, account_id: @member.id, role: 'member' }
    new_member = FairShare::GroupMember.create(member_data)

    _(new_member.id.is_a?(Numeric)).must_equal false
  end
end
