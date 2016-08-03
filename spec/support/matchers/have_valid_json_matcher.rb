RSpec::Matchers.define :have_valid_json do
  match do |response|
    begin
      JSON.parse response.body
      true
    rescue
      false
    end
  end
end
