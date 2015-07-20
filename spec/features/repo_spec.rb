require 'spec_helper'

describe 'Repository app' do
  context 'without a code parameter' do
    it 'displays a log in button' do
      visit '/apps/repos'
      expect(page).to have_content 'Login with GitHub'
    end
  end

  context 'with a code parameter' do
    before(:each) do
      visit '/apps/repos?code=bar'
    end

    it 'displays the app title' do
      expect(page).to have_content 'Repositories'
    end

    it 'displays a select box of organizations' do
      expect(page).to have_select('org_select', options: ['', 'FOO','BAR','BAZ'])
    end
  end
end
