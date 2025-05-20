# frozen_string_literal: true

require 'base64'
require 'rbnacl'

# Crypto methods for mixin
module Securable
  class NoKeyError < StandardError; end

  def generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 key
  end

  def setup(base_key)
    raise NoKeyError unless base_key

    @base_key = base_key
  end

  def key
    @key ||= Base64.strict_decode64(@base_key)
  end

  def base_encrypt(plaintext)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.encrypt(plaintext)
  end

  def base_decrypt(ciphertext)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.decrypt(ciphertext).force_encoding('UTF-8')
  end
end
