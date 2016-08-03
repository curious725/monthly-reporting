FactoryGirl.define do
  factory :team_role do
    role  'member'
    team
    user
  end
end
