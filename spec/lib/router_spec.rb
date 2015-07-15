require 'spec_helper'

describe Router do
  context 'accessing the root route' do
    context 'with trailing slash' do
      it 'returns a successful response' do
        get '/apps/repos/'
        expect(last_response.status).to eq 200
      end
    end

    context 'without trailing slash' do
      it 'returns a successful response' do
        get '/apps/repos'
        expect(last_response.status).to eq 200
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

  context 'accessing the authenticated' do
    it 'returns a redirected response' do
      get '/authenticated?app_name=foo&code=bar'
      expect(last_response.status).to eq 302
      expect(last_response.location).to eq 'http://example.org/apps/foo?code=bar'
    end
  end
end
