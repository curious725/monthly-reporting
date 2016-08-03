module Features
  module VacationsPageHelpers
    def user_sees_vacations_page
      expect(page).to have_current_path(root_path)
      expect(page).to have_current_fragment('vacations')
      user_sees_panel 'Request New Vacation'
      user_sees_panel 'List of Vacations'
    end

    def user_sees_simple_vacations_page
      user_sees_vacations_page
    end

    def user_sees_editable_vacations_page
      user_sees_vacations_page
    end
  end
end
