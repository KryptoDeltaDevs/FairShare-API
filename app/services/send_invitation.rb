# frozen_string_literal: true

require 'http'

module FairShare
  # Send email verfification email
  class SendInvitation
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(data, group_name, inviter_name)
      @data = data
      @group_name = group_name
      @inviter_name = inviter_name
    end

    def mj_apikey_public = ENV.fetch('MJ_APIKEY_PUBLIC')
    def mj_apikey_private = ENV.fetch('MJ_APIKEY_PRIVATE')
    def mj_api_url = ENV.fetch('MJ_API_URL')
    def mj_from_email = ENV.fetch('MJ_FROM_EMAIL')

    def call
      raise(InvalidRegistration, 'Email not exists') if email_unavailable?

      send_email_verification
    end

    def email_unavailable?
      Account.first(email: @data[:target_email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <h1>FairShare App Group Invitation</h1>
        <h2>You've been invited to #{@name} by #{@inviter_name}</h2
        <p>Click <a href="#{@data[:invitation_url]}">here</a> to accept the group invitation.</p>
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
                Email: @data[:target_email]
              }
            ],
            Subject: 'FairShare Group Invitation',
            HTMLPart: html_email
          }
        ]
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
