module Features
  module DashboardPageHelpers
    def user_sees_dashboard_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('dashboard')

      user_sees_menu_item 'Dashboard'
      user_sees_panel 'Vacations Time Table'

      expect(page).to have_content(team.name)
    end
  end
end
