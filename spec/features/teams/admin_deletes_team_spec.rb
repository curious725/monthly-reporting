require 'rails_helper'

RSpec.feature 'Admin deletes team', js: true do
  given(:user)          { create(:user) }
  given(:team)          { create(:team) }
  given(:another_team)  { create(:team) }

  background do
    another_team
    create(:team_role, user: user, team: team, role: 'admin')
    sign_in_with user.email, user.password
    click_on 'Teams'
  end

  scenario 'successfully' do
    expect(page).to     have_content('Sign out')
    expect(page).to     have_content(team.name)
    expect(page).to     have_content(another_team.name)

    node = page.find('.panel-heading', text: another_team.name)
    # Provides action related control
    expect(node).to have_css('button[name=delete]')
    node.find(:button, 'Delete').click

    expect(page).not_to have_content(another_team.name)
    expect(page).to     have_content(team.name)
  end
end
