# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module FairShare
  STORE_DIR = 'db/store'

  # Group detail
  class Group
    def initialize(new_group)
      @id = new_group['id'] || new_id
      @name = new_group['name']
      @description = new_group['description']
      @created_at = new_group['created_at'] || Time.now
    end

    attr_reader :id, :name, :description, :created_at

    def to_json(options = {})
      JSON(
        {
          id: @id,
          name: @name,
          description: @description,
          created_at: @created_at
        },
        options
      )
    end

    def self.setup
      FileUtils.mkdir_p(FairShare::STORE_DIR)
    end

    def save
      File.write("#{FairShare::STORE_DIR}/#{id}.txt", to_json)
    end

    def self.find(id)
      group = File.read("#{FairShare::STORE_DIR}/#{id}.txt")
      Group.new JSON.parse(group)
    end

    def self.all
      Dir.glob("#{FairShare::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(FairShare::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
