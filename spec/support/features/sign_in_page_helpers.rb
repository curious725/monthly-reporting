module Features
  module SignInPageHelpers
    def user_sees_sign_in_page
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_selector('h2', text: 'Log in')
      expect(page).to have_selector('label', text: 'Email')
      expect(page).to have_selector('label', text: 'Password')
      expect(page).to have_button('Log in')
    end
  end
end
