# frozen_string_literal: true

require 'http'

module FairShare
  # Send email verfification email
  class VerifyRegistration
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def mj_apikey_public = ENV.fetch('MJ_APIKEY_PUBLIC')
    def mj_apikey_private = ENV.fetch('MJ_APIKEY_PRIVATE')
    def mj_api_url = ENV.fetch('MJ_API_URL')
    def mj_from_email = ENV.fetch('MJ_FROM_EMAIL')

    def call
      raise(InvalidRegistration, 'Email exists') unless email_available?

      send_email_verification
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <h1>FairShare App Registration Received</h1>
        <p>Please <a href="#{@registration[:verification_url]}">Click here</a> to validate your email. You will be asked to set your name and a password to activate your account.</p>
      END_EMAIL
    end

    def mail_json # rubocop:disable Metrics/MethodLength
      {
        Messages: [
          {
            From: {
              Email: mj_from_email,
              Name: 'FairShare App'
            },
            To: [
              {
                Email: @registration[:email],
                Name: @registration[:name] || 'New User'
              }
            ],
            Subject: 'FairShare Registration Verification',
            HTMLPart: html_email
          }
        ]
        # personalizations: [{ to: [{ 'email' => @registration[:email] }] }],
        # from: { 'email' => from_email },
        # subject: 'FairShare Registration Verification',
        # content: [{ type: 'text/html', value: html_email }]
      }
    end

    def send_email_verification
      # res = HTTP.auth("Bearer #{mail_api_key}").post(mail_url, json: mail_json)
      res = HTTP.basic_auth(user: mj_apikey_public, pass: mj_apikey_private)
                .headers(content_type: 'application/json')
                .post(mj_api_url, json: mail_json)

      raise EmailProviderError if res.status >= 300
    rescue EmailProviderError
      raise EmailProviderError
    rescue StandardError
      raise(InvalidRegistration, 'Could not send verification email; please check email address')
    end
  end
end
