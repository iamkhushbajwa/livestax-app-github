require 'spec_helper'

describe 'Repository app' do
  context 'without a code parameter' do
    it 'displays a log in button' do
      visit '/apps/repos'
      expect(page).to have_content 'Login with GitHub'
    end
  end

  context 'with a code parameter' do
    it 'displays the app' do
      visit '/apps/repos?code=bar'
      expect(page).to have_content 'Repositories'
    end
  end
end
