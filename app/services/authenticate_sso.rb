# frozen_string_literal: true

require 'http'

module FairShare
  # Authenticate an SSO accoount by finding or creating one based on Github data
  class AuthenticateSSO
    # Either email or name not exist
    class MissingData < StandardError
      def message
        "Email or name isn't available"
      end
    end

    def call(access_token)
      gh_account = get_github_account(access_token)
      sso_account = find_or_create_sso_account(gh_account)

      AuthorizedAccount.new(sso_account, AuthScope::FULL).to_h
    end

    def get_github_response(url:, authorization:, accept:)
      HTTP.headers(
        user_agent: 'FairShare',
        authorization:,
        accept:
      ).get(url)
    end

    def get_github_account(access_token) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      gh_response = get_github_response(url: ENV.fetch('GITHUB_ACCOUNT_URL'), authorization: "token #{access_token}",
                                        accept: 'application/json')
      raise unless gh_response.status == 200

      response = JSON.parse(gh_response)
      gh_account = { 'login' => response['login'], 'email' => response['email'] }
      if gh_account['email'].nil?
        gh_response = get_github_response(url: "#{ENV.fetch('GITHUB_ACCOUNT_URL')}/emails",
                                          authorization: "Bearer #{access_token}",
                                          accept: 'application/vnd.github+json')
        emails = JSON.parse(gh_response).find { |data| data['primary'] && data['verified'] }
        raise MissingData if emails.nil?

        gh_account['email'] = emails['email']
      end
      account = GithubAccount.new(gh_account)
      { name: account.name, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end
  end
end
