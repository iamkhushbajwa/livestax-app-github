require 'spec_helper'

describe 'Repository app' do
  context 'without a signed request parameter' do
    context 'without a code parameter' do
      it 'displays a message' do
        visit "/apps/repos?"
        expect(page).to have_content 'This app requires Livestax'
      end
    end

    context 'with a code parameter' do
      it 'displays a message' do
        visit "/apps/repos?code=bar"
        expect(page).to have_content 'This app requires Livestax'
      end
    end
  end

  context 'with a signed request parameter' do
    context 'without a code parameter' do
      it 'displays a log in button' do
        visit "/apps/repos?signed_request=#{signed_request}"
        expect(page).to have_content 'Login with GitHub'
      end
    end

    context 'with a code parameter' do
      before(:each) do
        visit "/apps/repos?signed_request=#{signed_request}&code=bar"
      end

      it 'displays a select box of organizations' do
        expect(page).to have_select('org_select', options: ['', 'FOO','BAR','BAZ'])
      end

      it 'displys a notice requesting the user to select an org' do
        expect(page).to have_content 'Select Organization'
      end

      context 'selecting an organization', js: true do
        before(:each) do
          page.select 'FOO', from: 'org_select'
        end

        it 'displays the repositories from the organization' do
          expect(page).to have_content 'Repo 1'
        end

        it 'hides the notice requesting the user to select an org' do
          expect(page).not_to have_content 'Select Organization'
        end

        it 'redisplays the notice if user select no organization' do
          page.select '', from: 'org_select'
          expect(page).to have_content 'Select Organization'
        end

        context 'with no repositories', js: true do
          it 'displays the notice' do
            page.select 'BAZ', from: 'org_select'
            expect(page).to have_content 'No Repositories'
          end
        end
      end
    end
  end
end
