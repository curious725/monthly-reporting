module Features
  module HomePageHelpers
    def user_sees_home_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('')
    end
  end
end
