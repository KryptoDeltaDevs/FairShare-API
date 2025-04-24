# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test GroupMember Handling' do
  before do
    wipe_database

    DATA[:groups].each do |group_data|
      group = FairShare::Group.new(group_data)
      group.created_by = 1
      group.save_changes
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    member_data = DATA[:group_members][0]
    group = FairShare::Group.first
    new_member = group.add_group_member(member_data)

    member = FairShare::GroupMember.find(id: new_member.id)
    _(member.user_id).must_equal member_data['user_id']
    _(member.role).must_equal member_data['role']
  end

  it 'SECURITY: should not use deterministic integers' do
    member_data = DATA[:group_members][0]
    group = FairShare::Group.first
    new_member = group.add_group_member(member_data)

    _(new_member.id.is_a?(Numeric)).must_equal false
  end
end
