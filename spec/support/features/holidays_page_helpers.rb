module Features
  module HolidaysPageHelpers
    def user_sees_holidays_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('holidays')
      user_sees_panel 'Holidays'
    end

    def user_sees_editable_holidays_page
      user_sees_holidays_page

      expect(page).to have_button('Add')
    end

    def user_sees_readonly_holidays_page
      user_sees_holidays_page

      expect(page).not_to have_button('Add')
      expect(page).not_to have_button('Delete')
    end
  end
end
