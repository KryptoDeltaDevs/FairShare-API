# frozen_string_literal: true

require 'base64'
require_relative 'securable'
require_relative 'auth_scope'

# Token and Detokenize Authorization Information
class AuthToken
  extend Securable

  ONE_WEEK = 7 * 24 * 60 * 60

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end

  def initialize(token)
    @token = token
    contents = AuthToken.detokenize(@token)
    @expiration = contents['exp']
    @scope = contents['scope']
    @payload = contents['payload']
  end

  def expired?
    Time.now > Time.at(@expiration)
  rescue StandardError
    raise InvalidTokenError
  end

  def fresh? = !expired?

  def payload
    expired? ? raise(ExpiredTokenError) : @payload
  end

  def scope
    expired? ? raise(ExpiredTokenError) : @scope
  end

  def to_s = @token

  def self.create(payload, scope = AuthScope.new, expiration = ONE_WEEK)
    tokenize(
      'payload' => payload,
      'scope' => scope,
      'exp' => expires(expiration)
    )
  end

  def self.expires(expiration)
    (Time.now + expiration).to_i
  end

  def self.tokenize(message)
    return nil unless message

    message_json = message.to_json
    ciphertext = base_encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    message_json = base_decrypt(ciphertext)
    JSON.parse(message_json)
  rescue StandardError
    raise InvalidTokenError
  end
end
