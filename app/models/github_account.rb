# frozen_string_literal: true

module FairShare
  # Maps Github account details to attributes
  class GithubAccount
    def initialize(gh_account)
      @gh_account = gh_account
    end

    def name
      @gh_account['login']
    end

    def email
      @gh_account['email']
    end
  end
end
