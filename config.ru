if ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

require './lib/router'

run Router
