require 'sinatra'

class Router < Sinatra::Base
  set :protection, :except => [:frame_options]

  get '/' do
    "GitHub"
  end
end
