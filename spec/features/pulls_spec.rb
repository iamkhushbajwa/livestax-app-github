require 'spec_helper'

describe 'Pull Requests app' do
  context 'without a signed request parameter' do
    context 'without a code parameter' do
      it 'displays a message' do
        visit "/apps/pulls?"
        expect(page).to have_content 'This app requires Livestax'
      end
    end

    context 'with a code parameter' do
      it 'displays a message' do
        visit "/apps/pulls?code=bar"
        expect(page).to have_content 'This app requires Livestax'
      end
    end
  end

  context 'with a signed request parameter' do
    context 'without a code parameter' do
      it 'displays a log in button' do
        visit "/apps/pulls?signed_request=#{signed_request}"
        expect(page).to have_content 'Login with GitHub'
      end
    end

    context 'with a code parameter' do
      before(:each) do
        visit "/apps/pulls?signed_request=#{signed_request}&code=bar"
      end

      it 'displys a notice requesting the user to select a repo' do
        expect(page).to have_content 'Select Repository'
      end
    end
  end
end
