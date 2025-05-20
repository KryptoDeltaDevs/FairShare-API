# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require_app('lib')

module FairShare
  # Config
  class Api < Roda
    plugin :environments

    configure do
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8") # rubocop:disable Lint/ConstantDefinitionInBlock
      def self.DB = DB # rubocop:disable Naming/MethodName

      SecureDB.setup(ENV.delete('DB_KEY'))
      AuthToken.setup(ENV.fetch('MSG_KEY'))

      LOGGER = Logger.new($stderr) # rubocop:disable Lint/ConstantDefinitionInBlock
      def self.logger = LOGGER
    end

    configure :development, :production do
      plugin :common_logger, $stderr
    end

    configure :development, :test do
      require 'pry'
    end
  end
end
