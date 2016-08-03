require 'rails_helper'

RSpec.feature 'Admin renames team', js: true do
  given(:user)          { create(:user) }
  given(:team)          { create(:team) }
  given(:another_team)  { create(:team) }

  background do
    create(:team_role, user: user, team: team, role: 'admin')
    sign_in_with user.email, user.password
    click_on 'Teams'
  end

  context 'successfully, with valid input' do
    scenario 'name=Valiants' do
      team_name = 'Valiants'
      expect(page).to     have_content('Sign out')
      expect(page).to     have_content(team.name)
      expect(page).not_to have_content(team_name)

      node = page.find('.panel-heading', text: team.name)
      expect(node).to have_css('button[name=rename]')
      node.find(:button, 'Rename').click

      node.find(:css, 'input[name=team-name]').set(team_name)
      node.find(:css, 'button[name=update]').click

      expect(page).not_to have_content(team.name)
      expect(page).to     have_content(team_name)
    end
  end

  context 'unsuccessfully, with not valid input' do
    scenario 'name=Ants' do
      team_name = 'Ants'
      expect(page).to     have_content('Sign out')
      expect(page).to     have_content(team.name)
      expect(page).not_to have_content(team_name)

      node = page.find('.panel-heading', text: team.name)
      expect(node).to have_css('button[name=rename]')
      node.find(:button, 'Rename').click

      node.find(:css, 'input[name=team-name]').set(team_name)
      node.find(:css, 'button[name=update]').click

      expect(page).to     have_content(team.name)
      expect(page).not_to have_content(team_name)
    end
  end
end
