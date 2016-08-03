# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside
# the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# https://codedecoder.wordpress.com/2013/04/25/rake-db-seed-in-rails/
SLOGAN_WIDTH  = 60
STATUS_WIDTH  = 10
STATUS_OK     = '[ OK ]'.rjust(STATUS_WIDTH)
STATUS_FAIL   = '[ FAIL ]'.rjust(STATUS_WIDTH)

def report(slogan)
  msg = '[*] ' + slogan
  print msg.ljust(SLOGAN_WIDTH)
end

# *****************************************************************************
# Add some leaders
begin
  report 'Populating DB with users...'

  leaders = [
    { email: 'iron@i.ua',       first_name: 'J.A.R.V.I.S' },
    { email: 'prime@i.ua',      first_name: 'Optimus', last_name: 'Prime' },
    { email: 'megatron@i.ua',   first_name: 'Megatron' },
    { email: 'ironman@i.ua',    first_name: 'Tony', last_name: 'Stark' },
    { email: 'ironmaiden@i.ua', first_name: 'Pepper', last_name: 'Potts' }
  ]

  # Add some members for JARVIS's team
  @avengers_members = []
  5.times do |n|
    @avengers_members << { email: "suit#{n}@i.ua", first_name: "Suit#{n}" }
  end

  # Add some members for Optimus's team
  @autobots_members = []
  5.times do |n|
    @autobots_members << {
      email: "autobot#{n}@i.ua",
      first_name: "Autobot#{n}"
    }
  end

  # Add some members for Megatron's team
  @decepticons_members = []
  5.times do |n|
    @decepticons_members << {
      email: "decepticon#{n}@i.ua",
      first_name: "Decepticon#{n}"
    }
  end

  users = leaders + @avengers_members + @autobots_members + @decepticons_members

  # Provide users with super-strong-and-unique passwords :D
  users.each do |u|
    u['password'] = '123456secret'
  end

  # Create records in one transaction
  User.create users

  puts STATUS_OK
rescue
  puts STATUS_FAIL
end

# *****************************************************************************
# Populate DB with Teams
begin
  report 'Populating DB with teams...'

  @avengers    = Team.create(name: 'Avengers')
  @autobots    = Team.create(name: 'Autobots')
  @decepticons = Team.create(name: 'Decepticons')

  puts STATUS_OK
rescue
  puts STATUS_FAIL
end

# *****************************************************************************
# Assign leaders to their teams
begin
  report 'Assigning leaders to theirs teams...'

  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'J.A.R.V.I.S').id
    r.team_id = @avengers.id
  end

  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'Optimus').id
    r.team_id = @autobots.id
  end

  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'Megatron').id
    r.team_id = @decepticons.id
  end

  # Let Pepper to manage all the teams. True Iron Maiden :D
  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'Pepper').id
    r.team_id = @avengers.id
  end

  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'Pepper').id
    r.team_id = @autobots.id
  end

  TeamRole.create do |r|
    r.role    = 'manager'
    r.user_id = User.find_by(first_name: 'Pepper').id
    r.team_id = @decepticons.id
  end

  puts STATUS_OK
rescue
  puts STATUS_FAIL
end

# *****************************************************************************
# Populate teams with members
begin
  report 'Assigning users to theirs teams...'

  # ***************************************************************************
  # Form avengers team
  @avengers_members.each do |m|
    TeamRole.create do |r|
      r.role    = 'member'
      r.user_id = User.find_by(email: m[:email]).id
      r.team_id = @avengers.id
    end
  end
  TeamRole.create do |r|
    r.role    = 'guest'
    r.user_id = User.find_by(first_name: 'Optimus').id
    r.team_id = @avengers.id
  end
  TeamRole.create do |r|
    r.role    = 'guest'
    r.user_id = User.find_by(first_name: 'Megatron').id
    r.team_id = @avengers.id
  end

  # ***************************************************************************
  # Form avengers team
  @autobots_members.each do |m|
    TeamRole.create do |r|
      r.role    = 'member'
      r.user_id = User.find_by(email: m[:email]).id
      r.team_id = @autobots.id
    end
  end

  # ***************************************************************************
  # Form decepticons team
  @decepticons_members.each do |m|
    TeamRole.create do |r|
      r.role    = 'member'
      r.user_id = User.find_by(email: m[:email]).id
      r.team_id = @decepticons.id
    end
  end

  # ***************************************************************************
  # Let Tony become a guest
  TeamRole.create do |r|
    r.role    = 'guest'
    r.user_id = User.find_by(first_name: 'Tony').id
    r.team_id = @avengers.id
  end

  puts STATUS_OK
rescue
  puts STATUS_FAIL
end

# *****************************************************************************
# Populate teams with members
begin
  report 'Provide users with number of available vacations...'
  @number_of_users = User.count
  @vacations  = []
  @ids        = Array(1..@number_of_users).shuffle

  # Mega pack
  7.times do
    id = @ids.pop
    amount = rand(25..35)

    @vacations << { kind: 'planned',  user_id: id, available_days: amount }
    @vacations << { kind: 'sickness', user_id: id, available_days: 14.0 }
    @vacations << { kind: 'unpaid',   user_id: id, available_days:  5.0 }
  end

  # Full pack
  5.times do
    id = @ids.pop
    amount = rand(12..24)

    @vacations << { kind: 'planned',  user_id: id, available_days: amount }
    @vacations << { kind: 'sickness', user_id: id, available_days: 14.0 }
    @vacations << { kind: 'unpaid',   user_id: id, available_days:  5.0 }
  end

  # Average pack
  @ids.each do |id|
    amount = rand(1..11)

    @vacations << { kind: 'planned',  user_id: id, available_days: amount }
    @vacations << { kind: 'sickness', user_id: id, available_days: 14.0 }
    @vacations << { kind: 'unpaid',   user_id: id, available_days:  5.0 }
  end

  # Create records in one transaction
  AvailableVacation.create @vacations

  puts STATUS_OK
rescue
  puts STATUS_FAIL
end
