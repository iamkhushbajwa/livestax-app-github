require 'sinatra'

class Router < Sinatra::Base
  get '/' do
    "GitHub"
  end
end
