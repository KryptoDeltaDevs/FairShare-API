# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, groups, members, expenses, and payments'
    create_accounts
    create_groups
    add_members
    add_expenses
    add_payments
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
GROUPS_INFO = YAML.load_file("#{DIR}/groups_seed.yml")
EXPENSES_INFO = YAML.load_file("#{DIR}/expenses_seed.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account|
    FairShare::Account.create(account)
  end
end

def create_groups # rubocop:disable Metrics/MethodLength
  account = FairShare::Account.first
  GROUPS_INFO.each do |group|
    new_group = FairShare::Group.new(group)
    new_group.created_by = account.id
    new_group.save_changes

    FairShare::GroupMember.create(
      group_id: new_group.id,
      account_id: new_group.created_by,
      role: 'owner',
      can_add_expense: true
    )
  end
end

def add_members
  members = FairShare::Account.all
  members.shift
  groups = FairShare::Group.all
  groups.each do |group|
    members.each do |member|
      FairShare::GroupMember.create(group_id: group.id, account_id: member.id, role: 'member', can_add_expense: false)
    end
  end
end

def add_expenses # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
  group = FairShare::Group.first
  participants = FairShare::Account.all
  payer = participants[0]
  EXPENSES_INFO.each do |attrs|
    total_amount = attrs['total_amount'].to_f
    expense = FairShare::Expense.create(
      group_id: group.id,
      payer_id: payer.id,
      name: attrs['name'],
      description: attrs['description'],
      total_amount:
    )

    per_person = (total_amount / participants.count).round(2)
    participants.each do |participant|
      FairShare::ExpenseSplit.create(
        expense_id: expense.id,
        account_id: participant.id,
        amount_owed: per_person
      )
    end
  end

  group = FairShare::Group.last
  participants = FairShare::Account.all
  payer = participants[1]
  EXPENSES_INFO.each do |attrs|
    total_amount = attrs['total_amount'].to_f
    expense = FairShare::Expense.create(
      group_id: group.id,
      payer_id: payer.id,
      name: attrs['name'],
      description: attrs['description'],
      total_amount:
    )

    per_person = (total_amount / participants.count).round(2)
    participants.each do |participant|
      FairShare::ExpenseSplit.create(
        expense_id: expense.id,
        account_id: participant.id,
        amount_owed: per_person
      )
    end
  end
end

def add_payments
  account = FairShare::Account.last
  split_expense = account.split_expenses.first
  expense = account.expense_splits.find { |exp| exp.expense_id == split_expense.id }

  FairShare::Payment.create(
    expense_id: expense.expense_id,
    group_id: split_expense.group_id,
    from_account_id: expense.account_id,
    to_account_id: split_expense.payer_id,
    amount: expense.amount_owed
  )
end
