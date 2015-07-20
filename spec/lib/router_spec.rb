require 'spec_helper'

describe Router do
  context 'accessing the root route' do
    context 'without a signed request' do
      context 'with trailing slash' do
        it 'returns a successful response when POSTing' do
          post '/apps/repos/'
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'This app requires Livestax'
        end

        it 'returns a successful response when GETting' do
          get '/apps/repos/'
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'This app requires Livestax'
        end
      end

      context 'without trailing slash' do
        it 'returns a successful response when GETting' do
          post '/apps/repos'
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'This app requires Livestax'
        end

        it 'returns a successful response when GETting' do
          get '/apps/repos'
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'This app requires Livestax'
        end
      end
    end

    context 'with a signed request' do
      context 'with trailing slash' do
        it 'returns a successful response when POSTing' do
          post '/apps/repos/', signed_request: signed_request
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end

        it 'returns a successful response when GETting' do
          get "/apps/repos/?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end
      end

      context 'without trailing slash' do
        it 'returns a successful response when GETting' do
          post '/apps/repos', signed_request: signed_request
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end

        it 'returns a successful response when GETting' do
          get "/apps/repos?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end
      end
    end
  end

  context 'accessing the authenticate route' do
    context 'with trailing slash' do
      it 'returns a redirected response' do
        get '/auth/'
        expect(last_response.status).to eq 302
        expect(last_response.location).to eq "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_ID']}&redirect_uri=http%3A%2F%2Fexample.org%2Fauth%2Fcallback&response_type=code&scope=read%3Aorg"
      end
    end

    context 'without trailing slash' do
      it 'returns a redirected response' do
        get '/auth'
        expect(last_response.status).to eq 302
        expect(last_response.location).to eq "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_ID']}&redirect_uri=http%3A%2F%2Fexample.org%2Fauth%2Fcallback&response_type=code&scope=read%3Aorg"
      end
    end
  end

  context 'accessing the auth callback route' do
    context 'with trailing slash' do
      it 'returns a successful response' do
        get '/auth/callback/'
        expect(last_response.status).to eq 200
      end
    end

    context 'without trailing slash' do
      it 'returns a successful response' do
        get '/auth/callback'
        expect(last_response.status).to eq 200
      end
    end
  end

  context 'accessing /repos/:org' do
    context 'not logged in previously' do
      context 'without trailing slash' do
        it 'returns a successful response' do
          get "/repos/foo?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end
      end

      context 'with trailing slash' do
        it 'returns a successful response' do
          get "/repos/foo/?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Login with GitHub'
        end
      end
    end

    context 'logged in previously' do
      before(:each) do
        uuid = JWT.decode(signed_request, Router::REPO_APP_SECRET)[0]['user_id']
        Router.class_variable_set :@@token, {uuid => 'foobar'}
      end

      context 'without trailing slash' do
        it 'returns a successful response' do
          get "/repos/foo?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Repo 1'
        end
      end

      context 'with trailing slash' do
        it 'returns a successful response' do
          get "/repos/foo/?signed_request=#{signed_request}"
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Repo 1'
        end
      end
    end
  end
end
