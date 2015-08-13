require 'spec_helper'

describe Router do
  context 'accessing the repos app route' do
    context 'without a signed request' do
      context 'with trailing slash' do
        ['get', 'post'].each do |action|
          it "returns a successful response when #{action.upcase}ing" do
            send(action, '/apps/repos/')
            body_expectation(200, 'This app requires Livestax')
          end
        end
      end

      context 'without trailing slash' do
        ['get', 'post'].each do |action|
          it "returns a successful response when #{action.upcase}ing" do
            send(action, '/apps/repos')
            body_expectation(200, 'This app requires Livestax')
          end
        end
      end
    end

    context 'with a signed request' do
      context 'with trailing slash' do
        let!(:url) { '/apps/repos/' }
        it 'returns a successful response when POSTing' do
          post url, signed_request: signed_request
          body_expectation(200, 'Login with GitHub')
        end

        it 'returns a successful response when GETting' do
          get "#{url}?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end

      context 'without trailing slash' do
        let!(:url) { '/apps/repos' }
        it 'returns a successful response when POSTting' do
          post url, signed_request: signed_request
          body_expectation(200, 'Login with GitHub')
        end

        it 'returns a successful response when GETting' do
          get "#{url}?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end
    end
  end

  context 'accessing the pulls app route' do
    context 'without a signed request' do
      context 'with trailing slash' do
        ['get', 'post'].each do |action|
          it "returns a successful response when #{action.upcase}ing" do
            send(action, '/apps/pulls/')
            body_expectation(200, 'This app requires Livestax')
          end
        end
      end

      context 'without trailing slash' do
        ['get', 'post'].each do |action|
          it "returns a successful response when #{action.upcase}ing" do
            send(action, '/apps/pulls')
            body_expectation(200, 'This app requires Livestax')
          end
        end
      end
    end

    context 'with a signed request' do
      context 'with trailing slash' do
        let!(:url) { '/apps/pulls/' }
        it 'returns a successful response when POSTing' do
          post url, signed_request: signed_request
          body_expectation(200, 'Login with GitHub')
        end

        it 'returns a successful response when GETting' do
          get "#{url}?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end

      context 'without trailing slash' do
        let!(:url) { '/apps/pulls' }
        it 'returns a successful response when POSTting' do
          post url, signed_request: signed_request
          body_expectation(200, 'Login with GitHub')
        end

        it 'returns a successful response when GETting' do
          get "#{url}?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end
    end
  end

  context 'accessing the logout route' do
    context 'with trailing slash' do
      it 'returns a successful response' do
        get "/logout/?signed_request=#{signed_request}&app_name=repos"
        body_expectation(200, 'Redirecting you to the login page')
      end
    end

    context 'without trailing slash' do
      it 'returns a successful response' do
        get "/logout?signed_request=#{signed_request}&app_name=repos"
        body_expectation(200, 'Redirecting you to the login page')
      end
    end
  end

  context 'accessing the authenticate route' do
    context 'with trailing slash' do
      it 'returns a redirected response' do
        get '/auth/'
        location_expectation(302, "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_ID']}&redirect_uri=http%3A%2F%2Fexample.org%2Fauth%2Fcallback&response_type=code&scope=read%3Aorg")
      end
    end

    context 'without trailing slash' do
      it 'returns a redirected response' do
        get '/auth'
        location_expectation(302, "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_ID']}&redirect_uri=http%3A%2F%2Fexample.org%2Fauth%2Fcallback&response_type=code&scope=read%3Aorg")
      end
    end
  end

  context 'accessing the auth callback route' do
    context 'with trailing slash' do
      it 'returns a successful response' do
        get '/auth/callback/'
        status_expectation(200)
      end
    end

    context 'without trailing slash' do
      it 'returns a successful response' do
        get '/auth/callback'
        status_expectation(200)
      end
    end
  end

  context 'accessing /apps/repos/:org' do
    context 'not logged in previously' do
      context 'without trailing slash' do
        it 'returns a successful response' do
          get "/apps/repos/foo?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end

      context 'with trailing slash' do
        it 'returns a successful response' do
          get "/apps/repos/foo/?signed_request=#{signed_request}"
          body_expectation(200, 'Login with GitHub')
        end
      end
    end

    context 'logged in previously' do
      before(:each) do
        uuid = JWT.decode(signed_request, Router::REPOS_APP_SECRET)[0]['user_id']
        Router::REDIS.set(uuid, 'foobar')
      end

      context 'without trailing slash' do
        it 'returns a successful response' do
          get "/apps/repos/foo?signed_request=#{signed_request}"
          body_expectation(200, 'Repo 1')
        end
      end

      context 'with trailing slash' do
        it 'returns a successful response' do
          get "/apps/repos/foo/?signed_request=#{signed_request}"
          body_expectation(200, 'Repo 1')
        end
      end
    end
  end
end
