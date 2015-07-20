require 'oauth2'

class Github
  class << self
    def client
      OAuth2::Client.new(
        ENV['GITHUB_ID'],
        ENV['GITHUB_SECRET'],
        site: 'https://api.github.com',
        token_url: 'https://github.com/login/oauth/access_token',
        authorize_url: 'https://github.com/login/oauth/authorize'
      )
    end

    def authorize_url(url)
      client.auth_code.authorize_url(
        redirect_uri: redirect_uri(url),
        scope: SCOPE
      )
    end

    def get_token(code, url)
      client.auth_code.get_token(
        code,
        redirect_uri: redirect_uri(url)
      ).token
    end

    def redirect_uri(url)
      uri = URI.parse(url)
      uri.path = '/auth/callback'
      uri.query = nil
      uri.to_s
    end
  end

  attr_reader :authenticated_client

  SCOPE = ['read:org'].join(',')

  def initialize(token)
    @authenticated_client = OAuth2::AccessToken.new(self.class.client, token)
  end

  def organizations
    JSON.parse(authenticated_client.get("/user/orgs").body)
  end
end
