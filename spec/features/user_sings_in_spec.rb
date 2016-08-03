require 'rails_helper'

RSpec.feature 'User signs in' do
  given(:user) { create(:user) }

  background do
    visit root_path
  end

  context 'with valid email and password' do
    scenario 'successfully' do
      user_sees_sign_in_page

      sign_in_with user.email, user.password

      user_sees_home_page
      expect(page).to have_selector('.notice',
                                    text: 'Signed in successfully.')
    end
  end

  context 'with invalid email' do
    scenario 'and fails' do
      user_sees_sign_in_page

      sign_in_with 'invalid_email', user.password

      user_sees_sign_in_page
      expect(page).to have_selector('.alert',
                                    text: 'Invalid email or password.')
    end
  end

  context 'with blank password' do
    scenario 'and fails' do
      user_sees_sign_in_page

      sign_in_with user.email, ''

      user_sees_sign_in_page
      expect(page).to have_selector('.alert',
                                    text: 'Invalid email or password.')
    end
  end
end
