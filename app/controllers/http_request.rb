# frozen_string_literal: true

module FairShare
  # HTTP Request helper methods
  class HttpRequest
    def initialize(routing)
      @routing = routing
    end

    def secure?
      raise 'Secure scheme not configured' unless Api.config.SECURE_SCHEME

      @routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def body_data
      JSON.parse(@routing.body.read, symbolize_names: true)
    end
  end
end
