require 'rails_helper'

RSpec.feature 'User with all roles respects authorization', js: true do
  given(:user) { create(:user) }
  given(:team) { create(:team) }

  background do
    create(:team_role, user: user, team: team, role: 'admin')
    create(:team_role, user: user, team: team, role: 'manager')
    create(:team_role, user: user, team: team, role: 'member')
    create(:team_role, user: user, team: team, role: 'guest')
    sign_in_with user.email, user.password
  end

  context 'and can visit' do
    scenario 'Dashboard page' do
      user_sees_home_page
      user_sees_menu_item 'Dashboard'

      click_link 'Dashboard'

      user_sees_dashboard_page
    end

    scenario 'Vacations page' do
      user_sees_home_page
      user_sees_menu_item 'Vacations'

      click_link 'Vacations'

      user_sees_editable_vacations_page
    end

    scenario 'Holidays page' do
      user_sees_home_page
      user_sees_menu_item 'Holidays'

      click_link 'Holidays'

      user_sees_editable_holidays_page
    end

    scenario 'Teams page' do
      user_sees_home_page
      user_sees_menu_item 'Teams'

      click_link 'Teams'

      user_sees_teams_page
    end

    scenario 'Users page' do
      user_sees_home_page
      user_sees_menu_item 'Users'

      click_link 'Users'

      user_sees_users_page
    end

    scenario 'Sign out' do
      user_sees_home_page
      user_sees_menu_item 'Sign out'

      click_link 'Sign out'

      user_sees_sign_in_page
      user_sees_menu_item 'Sign in'
    end
  end
end
