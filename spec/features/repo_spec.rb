require 'spec_helper'

describe 'Repository app' do
  it 'displays a log in button' do
    visit '/repos'
    expect(page).to have_content 'Login with GitHub'
  end
end
