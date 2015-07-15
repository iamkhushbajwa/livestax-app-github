require 'sinatra'

class Router < Sinatra::Base
  set :protection, :except => [:frame_options]
  set :public_dir, 'public'

  get "/apps/repos/?" do
    erb :login
  end
end
