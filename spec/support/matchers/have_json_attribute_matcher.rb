# Augmentation to get Undersore like '_.pluck()' method
module Enumerable
  def pluck(key)
    map { |object| object[key] }
  end
end

# The matcher can be used as follows:
# it 'should respond with proper data' do
#   expect(response.body).to have_json_attribute(:name)
#     .with_value(another_team.name)
#   expect(response.body).to have_json_attribute(:id)
#     .with_value(team.id)
# end
RSpec::Matchers.define :have_json_attribute do |expected|
  match do |response_body|
    begin
      attribute = expected.to_s
      result = JSON.parse response_body
      has_key   = true
      has_value = true

      if result.class == Array
        values = result.pluck(attribute)
        has_key   = result[0].key?(attribute)
        has_value = values.include?(@value) unless @value.nil? && !has_key
      elsif result.class == Hash
        has_key   = result.key?(attribute)
        has_value = (result[attribute] == @value) unless @value.nil?
      end

      has_key && has_value
    rescue
      false
    end
  end

  chain :with_value do |value|
    @value = value
  end
end
