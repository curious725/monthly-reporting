# The matcher is to be used with Capybara page object.
# The following example checks if the URI is '/#holidays':
# scenario 'Holidays page' do
#   expect(page).to have_current_path(root_path)
#   expect(page).to have_current_fragment('holidays')
# end
RSpec::Matchers.define :have_current_fragment do |expected|
  match do |actual|
    begin
      @actual = actual.current_url
      fragment = URI.parse(@actual).fragment.to_s

      fragment == expected
    rescue
      false
    end
  end
end
