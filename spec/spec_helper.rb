require 'dotenv'
Dotenv.load

require 'rack/test'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'fakeredis/rspec'
require 'router'
require 'github'

def app
  @app ||= Router
end

def signed_request
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpbnN0YW5jZV9pZCI6IjhiOTUwZTIxMGRhNzcyYzNiZTk0MTkzNTA3NzJhZDE4IiwidGltZXN0YW1wIjoxNDExNTQ5ODczLCJ1c2VyX2lkIjoiNjc1YmVkYWEtZTdlNC00Yzg2LTgxYTQtN2E2NTVhNDU5NTIwIiwiaXNfYWRtaW4iOnRydWUsImlzX2d1ZXN0IjpmYWxzZX0.IzDmQv20nZvjIJYsx4Hv6J6uj5DhurspJjf9kkHcm30'
end

Capybara.app = app
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:each) do
    organizations = [
      {'login' => 'foo'},
      {'login' => 'bar'},
      {'login' => 'baz'}
    ]

    org_repos = {
      'foo' => [
        {'name' => 'Repo 1'}
      ],
      'bar' => [
        {'name' => 'Repo 2'},
        {'name' => 'Repo 3'}
      ],
      'baz' => []
    }

    stub_const('Router::REPO_APP_SECRET', 'secret')
    stub_const("Router::REDIS", Redis.new)
    allow_any_instance_of(Github).to receive(:organizations).and_return(organizations)
    allow_any_instance_of(Github).to receive(:organization_repos).with(any_args) do |request, org|
      org_repos[org]
    end
    allow(Github).to receive(:get_token).and_return('foobar')
  end

  config.after(:each) do
    Router::REDIS.flushdb
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Capybara::DSL
  config.include Rack::Test::Methods
end
