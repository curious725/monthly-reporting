# Augmentation to get Undersore like '_.pluck()' method
module Enumerable
  def pluck(key)
    map { |object| object[key] }
  end
end

RSpec::Matchers.define :match_records_by_ids do |models|
  match do |response_body|
    records = JSON.parse response_body
    @body_records_ids = records.pluck('id')
    @models_ids = models.pluck('id')

    have_same_ids = @body_records_ids == @models_ids
    have_even_number_of_records = records.length == models.length

    have_same_ids && have_even_number_of_records
  end

  description do
    'match records in response body with provided collection of models'
  end

  failure_message do
    "expected #{@body_records_ids} to match #{@models_ids}"
  end

  failure_message_when_negated do
    "expected #{@body_records_ids} not to match #{@models_ids}"
  end
end

RSpec::Matchers.alias_matcher :match_records_by_ids_with, :match_records_by_ids
