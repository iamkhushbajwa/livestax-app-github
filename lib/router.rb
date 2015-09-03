require 'sinatra'
require "damerau-levenshtein"
require_relative 'github'
require_relative 'fuzzy_match'
require_relative 'user'

configure do
  require 'redis'
  redis_uri = URI.parse(ENV['REDIS_URL'])
  REPOS_APP_SECRET = ENV['REPOS_APP_SECRET']
  PULLS_APP_SECRET = ENV['PULLS_APP_SECRET']
  REDIS = Redis.new(
    host: redis_uri.host,
    port: redis_uri.port,
    password: redis_uri.password
  )
end

class Router < Sinatra::Base
  set :protection, :except => [:frame_options]
  set :public_dir, 'public'

  def self.get_or_post(url, &block)
    get(url, &block)
    post(url, &block)
  end

  get_or_post "/apps/repos/?" do
    require_client do |client|
      user_uuid = validate_signed_request(@signed_request, @app)['user_id']
      @orgs = client.organizations.map{|org| org['login']}
      @selected_org = authenticated?(user_uuid) ? select_org(user_uuid, @orgs) : ''
      erb :repos
    end
  end

  get_or_post "/apps/pulls/?" do
    require_client do |client|
      erb :pulls
    end
  end

  get "/auth/?" do
    redirect Github.authorize_url(request.url)
  end

  get "/auth/callback/?" do
    erb :auth_callback
  end

  get "/logout/?" do
    @signed_request = params[:signed_request]
    @app = params[:app_name]
    uuid = validate_signed_request(@signed_request, @app)['user_id']
    REDIS.del(uuid)
    erb :logout
  end

  get "/apps/repos/:org/?" do |org|
    require_client do |client|
      client.organization_repos(org).map{|repo| repo['name']}.to_json
    end
  end

  private

  def require_client
    @signed_request = params[:signed_request]
    @app = request.path_info.split("/")[2]
    return 'This app requires Livestax' if !@signed_request
    uuid = validate_signed_request(@signed_request, @app)['user_id']

    if token = REDIS.get(uuid)
      return yield(Github.new(token))
    end

    if code = params[:code]
      token = Github.get_token(code, request.url)
      REDIS.set(uuid, token) if authenticated?(uuid)
      yield(Github.new(token))
    else
       erb(:login)
    end
  end

  def authenticated?(uuid)
    !!uuid
  end

  def select_org(user_uuid, orgs)
    user = User::fetch(user_uuid, REPOS_APP_SECRET)
    org_name = user.primary_organization ? user.primary_organization.name : ''
    FuzzyMatch.new(org_name, orgs).closest
  end

  def validate_signed_request(signed_request, app)
    secret = eval("#{app.upcase}_APP_SECRET")
    JWT.decode(signed_request, secret)[0]
  end
end
