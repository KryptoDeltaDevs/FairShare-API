# frozen_string_literal: true

require 'json'
require 'sequel'

module FairShare
  # Group detail
  class Group < Sequel::Model
    plugin :uuid, field: :id
    one_to_many :group_members
    plugin :association_dependencies, group_members: :destroy

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :name, :description

    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          data: {
            type: 'group',
            attributes: {
              id:,
              name:,
              description:,
              created_by:,
              created_at:,
              updated_at:
            }
          }
        }, options
      )
    end
  end
end
