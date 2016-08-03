# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'shoulda/matchers'
require 'pundit/rspec'
require 'ffaker'
require 'database_cleaner'
require 'capybara/poltergeist'

ActiveRecord::Migration.maintain_test_schema!
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Features::UserInterfaceHelpers, type: :feature
  config.include Features::SessionHelpers, type: :feature
  config.include Features::SignInPageHelpers, type: :feature
  config.include Features::HomePageHelpers, type: :feature
  config.include Features::DashboardPageHelpers, type: :feature
  config.include Features::VacationsPageHelpers, type: :feature
  config.include Features::HolidaysPageHelpers, type: :feature
  config.include Features::TeamsPageHelpers, type: :feature
  config.include Features::UsersPageHelpers, type: :feature

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy= example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
