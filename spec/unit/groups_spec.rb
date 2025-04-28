# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Group Handling' do
  before do
    wipe_database
    @account = FairShare::Account.create(DATA[:accounts][0])
  end

  it 'HAPPY: should retrieve correct data from database' do
    group_data = DATA[:groups][0]
    new_group = FairShare::Group.new(group_data)
    new_group.created_by = @account.id
    new_group.save_changes

    group = FairShare::Group.find(id: new_group.id)
    _(group.name).must_equal group_data['name']
    _(group.description).must_equal group_data['description']
  end

  it 'SECURITY: should not use deterministic integers' do
    group_data = DATA[:groups][0]
    new_group = FairShare::Group.new(group_data)
    new_group.created_by = @account.id
    new_group.save_changes

    _(new_group.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    group_data = DATA[:groups][0]
    new_group = FairShare::Group.new(group_data)
    new_group.created_by = @account.id
    new_group.save_changes

    _(new_group[:name_secure]).wont_equal group_data['name']
    _(new_group[:description_secure]).wont_equal group_data['description']
  end
end
