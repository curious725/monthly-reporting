FactoryGirl.define do
  factory :holiday  do
    description { "#{Time.now.usec} Day" }
    duration    1
    start       { Time.zone.today.to_s }
  end
end
