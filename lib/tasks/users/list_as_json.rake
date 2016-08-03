namespace :users do
  desc 'List all the users from DB in JSON format, with fields required for user creation, except the password one'
  task list_as_json: :environment do
    COLS = %i(id first_name last_name email birth_date employment_date)

    User
      .select(COLS)
      .all
      .each do |user|
        puts user.attributes.to_json
      end
  end
end
