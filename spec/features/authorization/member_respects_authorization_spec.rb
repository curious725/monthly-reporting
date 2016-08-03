require 'rails_helper'

RSpec.feature 'Member respects authorization', js: true do
  given(:user) { create(:user) }
  given(:team) { create(:team) }

  background do
    create(:team_role, user: user, team: team, role: 'member')
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

      user_sees_simple_vacations_page
    end

    scenario 'Holidays page' do
      user_sees_home_page
      user_sees_menu_item 'Holidays'

      click_link 'Holidays'

      user_sees_readonly_holidays_page
    end

    scenario 'Sign out' do
      user_sees_home_page
      user_sees_menu_item 'Sign out'

      click_link 'Sign out'

      user_sees_sign_in_page
      user_sees_menu_item 'Sign in'
    end
  end

  context 'and cannot visit' do
    scenario 'Teams page' do
      user_sees_home_page
      user_does_not_see_menu_item 'Teams'

      visit '/#teams'

      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('teams')

      user_does_not_see_panel 'Teams'
      user_sees_alert 'Access denied'
    end

    scenario 'Users page' do
      user_sees_home_page
      user_does_not_see_menu_item 'Users'

      visit '/#users'

      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('users')

      user_does_not_see_panel 'Users'
      user_sees_alert 'Access denied'
    end
  end
end
