# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Add Member service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      FairShare::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = FairShare::AuthenticateAccount.call(email: credentials['email'], password: credentials['password'])
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      FairShare::AuthenticateAccount.call(
        email: credentials['email'],
        password: 'password'
      )
    }).must_raise FairShare::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      FairShare::AuthenticateAccount.call(
        email: 'anemail@gmail.com',
        password: 'password'
      )
    }).must_raise FairShare::AuthenticateAccount::UnauthorizedError
  end
end
