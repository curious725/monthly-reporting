module Features
  module UserInterfaceHelpers
    # Bootstrap Menu
    def user_sees_menu_item(title)
      expect(page).to have_selector('#navbar', text: title)
    end

    def user_does_not_see_menu_item(title)
      expect(page).not_to have_selector('#navbar', text: title)
    end

    # Bootstrap Panel
    def user_sees_panel(title)
      expect(page).to have_selector('.panel-heading', text: title)
    end

    def user_does_not_see_panel(title)
      expect(page).not_to have_selector('.panel-heading', text: title)
    end

    # Alerts
    def user_sees_alert(message)
      expect(page).to have_selector('.alert', text: message)
    end

    def user_does_not_see_alert(message)
      expect(page).not_to have_selector('.alert', text: message)
    end
  end
end
