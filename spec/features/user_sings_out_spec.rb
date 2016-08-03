require 'rails_helper'

RSpec.feature 'User signs out' do
  given(:user) { create(:user) }

  background do
    sign_in_with user.email, user.password
  end

  scenario 'successfully' do
    user_sees_home_page
    user_sees_menu_item 'Sign out'

    click_link 'Sign out'

    user_sees_sign_in_page
    user_sees_menu_item 'Sign in'
    expect(page).to have_selector('.notice', text: 'Signed out successfully.')
  end
end
