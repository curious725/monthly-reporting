FactoryGirl.define do
  factory :available_vacation do
    available_days  5
    kind            'planned'
    user
  end
end
