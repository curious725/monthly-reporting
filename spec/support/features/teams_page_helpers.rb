module Features
  module TeamsPageHelpers
    def user_sees_teams_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('teams')
      user_sees_panel 'Create New Team'
      user_sees_panel 'Teams'
    end
  end
end
