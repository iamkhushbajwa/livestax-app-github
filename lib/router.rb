require 'sinatra'
require_relative 'github'

class Router < Sinatra::Base
  set :protection, :except => [:frame_options]
  set :public_dir, 'public'

  get "/apps/repos/?" do
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

  get "/authenticated" do
    redirect "/apps/#{params['app_name']}?code=#{params['code']}"
  end

  def require_client
    code = params[:code]
    if code
      token = Github.get_token(code, request.url)
      yield(Github.new(token))
    else
       erb(:login)
    end
  end
end
