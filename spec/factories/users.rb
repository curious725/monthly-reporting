FactoryGirl.define do
  factory :user do
    email { "#{first_name.downcase}.#{last_name.downcase}@i.ua" }
    first_name      { FFaker::Name.first_name }
    last_name       { FFaker::Name.last_name }
    birth_date      { Date.new(1980, 5, 25) }
    employment_date { Date.new(2015, 1, 1) }
    password        'myPrecious'

    trait :with_vacations_of_all_statuses do
      start_date = Time.zone.today
      after :create do |user|
        VacationRequest.statuses.each_value do |status|
          start_date += 3.days
          FactoryGirl.create  :vacation_request,
                              status: status,
                              start_date: start_date,
                              end_date: start_date + 2.days,
                              user: user
        end
      end
    end

    trait :with_available_vacations do
      after :create do |user|
        AvailableVacation.kinds.each_value do |kind|
          FactoryGirl.create  :available_vacation,
                              available_days: 15,
                              kind: kind,
                              user: user
        end
      end
    end
  end
end
