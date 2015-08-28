require 'dotenv'
Dotenv.load

require 'rack/test'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'fakeredis/rspec'
require 'webmock/rspec'
require 'router'
require 'github'

def app
  @app ||= Router
end

def signed_request(opts={})
  data = {
    instance_id: "8b950e210da772c3be9419350772ad18",
    timestamp: Time.now.to_i,
    user_id: "675bedaa-e7e4-4c86-81a4-7a655a459520",
    is_admin: true,
    is_guest: false
  }.merge(opts)

  JWT.encode(data, 'secret')
end

def user_data(opts={})
  {
    organizations: [
      {
        slug: "s",
        name: "Public"
      }
    ],
    last_name: "User",
    full_name: "Example User",
    first_name: "Example"
  }.merge(opts).to_json
end

def build_org(org)
  {
    slug: org,
    name: org
  }
end

def build_user_options_hash(opts)
  data = {}
  return data unless opts.include?('=')
  opts.split('&').each do |opt_string|
    opt = opt_string.split('=')
    if opt[0] == 'org'
      data[:organizations] = [
        build_org(opt[1])
      ]
    else
      data[opt[0]] = opt[1]
    end
  end
  data
end

def status_expectation(status)
  expect(last_response.status).to eq status
end

def body_expectation(status, body)
  status_expectation(status)
  expect(last_response.body).to include body
end

def location_expectation(status, url)
  status_expectation(status)
  expect(last_response.location).to eq url
end

Capybara.app = app
Capybara.javascript_driver = :poltergeist
WebMock.disable_net_connect!(allow_localhost: true)

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

    stub_const('Router::REPOS_APP_SECRET', 'secret')
    stub_const('Router::PULLS_APP_SECRET', 'secret')
    stub_const("Router::REDIS", Redis.new)
    allow_any_instance_of(Github).to receive(:organizations).and_return(organizations)
    allow_any_instance_of(Github).to receive(:organization_repos).with(any_args) do |request, org|
      org_repos[org]
    end
    allow(Github).to receive(:get_token).and_return('foobar')

    stub_request(:any, /#{ENV['LIVESTAX_USER_URL']}\/user\/[-|\w]+/)
      .to_return(lambda { |request|
        opts = request.uri.path.to_s.split("/").last
        data = build_user_options_hash(opts)
        {status: 200, body: user_data(data), headers: {}}
      })
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
