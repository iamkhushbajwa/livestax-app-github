require 'spec_helper'

describe Router do
  context 'accessing the root route' do
    context 'with trailing slash' do
      it 'returns a successful response' do
        get '/repos/'
        expect(last_response.status).to eq 200
      end
    end

    context 'without trailing slash' do
      it 'returns a successful response' do
        get '/repos'
        expect(last_response.status).to eq 200
      end
    end
  end
end
