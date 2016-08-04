source 'https://rubygems.org'
ruby '2.2.1'


gem 'pg'
gem 'rails', '4.2.3'
gem 'whenever', require: false
gem 'clockwork', '~> 2.0'
gem 'mysql2', '~> 0.3.20'
gem 'jbuilder', '~> 2.0'
gem 'devise', '3.5.2'
gem 'devise_invitable'
gem 'pundit'

group :development, :test do
  gem 'spring'
  gem 'jasmine'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.5'
end

group :development do
  gem 'brice',          require: false
  gem 'hirb',           require: false
  gem 'awesome_print',  require: false
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'poltergeist'
  gem 'shoulda-matchers', '< 3.0', require: false
  gem 'ffaker',           require: false
end

gem 'dotenv-rails', groups: [:development, :test]

# Assets
gem 'therubyracer'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'haml', '~> 4.0.7'
gem 'haml-rails', '~> 0.9'
gem 'ruby-haml-js'
gem 'bootstrap-sass', '~> 3.3'

# Heroku
gem 'rails_12factor', group: :production
gem 'puma'
