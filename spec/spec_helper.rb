require 'dotenv'
Dotenv.load

require 'rack/test'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'router'
require 'github'

def app
  @app ||= Router
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
      'baz' => [
        {'name' => 'Repo 4'}
      ]
    }
    allow_any_instance_of(Github).to receive(:organizations).and_return(organizations)
    allow_any_instance_of(Github).to receive(:organization_repos).with(any_args) do |request, org|
      org_repos[org]
    end
    allow(Github).to receive(:get_token).and_return('foobar')
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include Capybara::DSL
  config.include Rack::Test::Methods
end
