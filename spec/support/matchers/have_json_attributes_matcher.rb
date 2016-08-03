# Matcher that checks if JSON data contain expected attributes
# Does not check ordering, that is, the following objects are equal:
# {:a, :b}, {:b, :a}
# The matcher can be used as follows:
# it 'should respond with properly structured records' do
#   expected = %w(id role team_id user_id)
#   expect(response.body).to have_json_attributes(expected)
# end

RSpec::Matchers.define :have_json_attributes do |expected|
  match do |response_body|
    fail ArgumentError, "Expectation must be #{Array.name}" \
      unless expected.instance_of?(Array)

    begin
      @result = JSON.parse response_body
      @expected = expected
      match?
    rescue
      false
    end
  end

  def match?
    if @result.empty?
      @result == @expected
    elsif @result.instance_of? Array
      @result.first.keys - @expected == @expected - @result.first.keys
    else
      @result.keys - @expected == @expected - @result.keys
    end
  end

  failure_message do
    if @result.instance_of? Array
      array_failure_message
    elsif @result.instance_of? Hash
      one_record_failure_message
    else
      fail ArgumentError, "Result must be #{Array.name} or #{Hash.name}"
    end
  end

  def array_failure_message
    if @result.first.nil?
      "expected [] to match #{@expected}"
    else
      "expected #{@result.first.keys} to match #{@expected}"
    end
  end

  def one_record_failure_message
    if @result.nil?
      "expected [] to match #{@expected}"
    else
      "expected #{@result.keys} to match #{@expected}"
    end
  end

  failure_message_when_negated do
    if @result.instance_of? Array
      array_failure_message_when_negated
    elsif @result.instance_of? Hash
      one_record_failure_message_when_negated
    else
      fail ArgumentError, "Result must be #{Array.name} or #{Hash.name}"
    end
  end

  def array_failure_message_when_negated
    if @result.first.nil?
      "expected [] not to match #{@expected}"
    else
      "expected #{@result.first.keys} not to match #{@expected}"
    end
  end

  def one_record_failure_message_when_negated
    if @result.nil?
      "expected [] not to match #{@expected}"
    else
      "expected #{@result.keys} not to match #{@expected}"
    end
  end
end
