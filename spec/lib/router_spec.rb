require 'spec_helper'

describe Router do
  context 'accessing the root route' do
    it 'returns a successful response' do
      get '/'
      expect(last_response.status).to eq 200
    end
  end
end
