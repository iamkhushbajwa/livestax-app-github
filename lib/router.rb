require 'sinatra'
require_relative 'github'

class Router < Sinatra::Base
  set :protection, :except => [:frame_options]
  set :public_dir, 'public'
  @@token = {}
  REPO_APP_SECRET = ENV['REPO_APP_SECRET']

  def self.get_or_post(url, &block)
    get(url, &block)
    post(url, &block)
  end

  get_or_post "/apps/repos/?" do
    require_client do |client|
      @orgs = client.organizations.map{|org| org['login']}
      erb :repos
    end
  end

  get "/auth/?" do
    redirect Github.authorize_url(request.url)
  end

  get "/auth/callback/?" do
    erb :auth_callback
  end

  get "/repos/:org/?" do |org|
    require_client do |client|
      client.organization_repos(org).map{|repo| repo['name']}.to_json
    end
  end

  def require_client
    @signed_request = params[:signed_request]
    return 'This app requires Livestax' if !@signed_request
    uuid = validate_signed_request(params[:signed_request])['user_id']

    if token = @@token[uuid]
      return yield(Github.new(token))
    end

    if code = params[:code]
      token = @@token[uuid] = Github.get_token(code, request.url)
      yield(Github.new(token))
    else
       erb(:login)
    end
  end

  def validate_signed_request(signed_request)
    JWT.decode(signed_request, REPO_APP_SECRET)[0]
  end
end
