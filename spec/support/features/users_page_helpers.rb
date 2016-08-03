module Features
  module UsersPageHelpers
    def user_sees_users_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('users')

      user_sees_panel 'Users'
      expect(page).to have_button('Add New User')
    end
  end
end
