# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'this is a password'
    digest = FairShare::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'this is a password'
    digest_s = FairShare::Password.digest(password).to_s

    digest = FairShare::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'this is a password'
    password2 = 'this is another password'
    digest_s1 = FairShare::Password.digest(password1).to_s

    true_password1 = FairShare::Password.from_digest(digest_s1)
    _(true_password1.correct?(password2)).must_equal false
  end
end
