namespace :users do
  desc 'Calculate available vacations for all the users in DB, and save results in appropriate records in DB'
  task calculate_available_vacations: :environment do
    require File.join(Rails.root,
                      'lib', 'services', 'calculate_available_vacations')

    User.all.each do |user|
      service = CalculateAvailableVacations.new(user, verbose: true)
      service.run
    end
  end
end
