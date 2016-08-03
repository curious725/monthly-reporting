#   Step by Step Instructions

##  Useful links
https://github.com/turingschool/lesson_plans/tree/master/ruby_02-web_applications_with_ruby
http://condor.depaul.edu/sjost/it231/documents/one-to-many.htm

https://github.com/preston/railroady

http://ondras.zarovi.cz/sql/demo/?keyword=vacations

Devise related screencasts:
http://railscasts.com/episodes/209-introducing-devise


##  Models
### `User`
- Generate User model:
```
rails g model User \
    first_name:string \
    last_name:string \
    position:string \
    birth_date:date \
    username:string:uniq
```
- Define relations:
  ```ruby
  has_many  :team_roles
  has_many  :vacation_requests
  has_many  :available_vacations
  has_many  :approval_requests
  ```


### `Team`
- Generate model:
  ```
  rails g model Team \
      name:string
  ```
- Define relations:
  ```ruby
  has_many  :team_roles
  ```


### `TeamRole`
- Generate model:
  ```
  rails g model TeamRole \
      role:string \
      user:references \
      team:references
  ```


### `VacationRequest`
- Generate model:
  ```
  rails g model VacationRequest \
      type:string \
      start:date \
      end:date \
      duration:integer \
      status:string \
      user:references
  ```
- Define relations:
  ```ruby
  has_many  :approval_requests
  ```


### `ApprovalRequest`

- Generate model:
  ```
  rails g model ApprovalRequest \
      manager_id:integer \
      vacation_request:references
  ```
- Define relations:
  ```ruby
  belongs_to  :user, foreign_key: :manager_id
  ```


### `AvailableVacation`
- Generate model:
  ```
  rails g model AvailableVacation \
      type:string \
      available_days:float \
      user:references
  ```


### `DayOff`
- Generate model:
  ```
  rails g model DayOff \
      description:string \
      start:date \
      duration:integer
  ```




##  Migrations

### `Role`
- Generate model:
  ```
  rails g model Role \
      name:string
  ```
- Update model:
  ```ruby
  has_many  :team_roles
  ```
- Generate migration
  ```
  rails g migration ChangeRoleTypeInTeamRoles
  ```
- Describe migration inside `change` method:
  ```ruby
  rename_column :team_roles, :role, :role_id
  change_column :team_roles, :role_id, :integer, references: :roles
  ```

### `VacationType`
- Generate model:
  ```
  rails g model VacationType \
      name:string
  ```
- Update model:
  ```ruby
  has_many  :vacation_requests
  has_many  :available_vacations
  ```
- Generate migrations for updating `vacation_requests` and `available_vacations`


### `VacationStatus`
- Generate model:
  ```
  rails g model VacationStatus \
      name:string
  ```
- Update model:
  ```ruby
  has_many  :vacation_requests
  ```
- Update `VacationRequest` model:
  ```
  belongs_to  :vacation_statuses
  ```
- Add the following migration:


##  Integrate Devise
### Add the core `devise`
- Run the `bundle` command to install it.
- Add the following line to the `Gemfile`:
  ```ruby
  gem 'devise'
  ```
- Create initializer:
  ```
  rails g devise:install
  ```
- Integrate into `User` model:
  ```
  rails g devise User
  ```
- Remove `registerable` from the model:
- Update DB:
  ```
  rake db:migrate
  ```


### Add Devise extension `devise_invitable`
- Add the following line to the `Gemfile`:
  ```ruby
  gem 'devise_invitable'
  ```
- Update Devise initializer:
  ```
  rails g devise_invitable:install
  ```
- Integrate into `User` model:
  ```
  rails g devise_invitable User
  ```
- Update DB:
  ```
  rake db:migrate
  ```


### Update Application view
- Add links for login/logout


### Update secrets
- Add SMTP email account credentials


### Add `Teams` controllers
- Update `routes.rb` as follows
  ```ruby
  root to: 'teams#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  resources :teams
  ```
- Generate controller
  ```
  rails g controller Teams
  ```
- Add view for the `teams#index`


### Add Devise controllers
- For `User`
  ```
  rails g devise:controllers users
  ```
- Remove controllers that are not needed yet


### Configure Mailer
- Update `config/environments/development.rb`

##  Views
- Add flash messages into Application view by adding the following:
  ```
  <p class="notice"><%= notice %></p>
  <p class="alert"><%= alert %></p>
  ```

##  Backbone
### Integration
- Check assets path list within `rails c`
  ```ruby
  Rails.application.config.assets.paths
  ```
- Clear the pipeline.
- Create application tree:
```
mkdir -v app/assets/javascripts/{collections,models,routers,views,templates}
```
- Update js manifest
- Add corresponding map-files


## Integrate `Jasmine`
- Add `jasmine` gem
- Install Jasmine:
  ```
  rails g jasmine:install
  ```
- Generate examples:
  ```
  rails g jasmine:examples
  ```
- Start Jasmine test server:
  ```
  rake jasmine
  ```


## Integrate HAML
- Add `ruby-haml-js` gem
  ```ruby
  gem 'ruby-haml-js'
  ```

##  UML
- Generate UML diagram for the models:
  ```
  railroady -M | dot -Tsvg > models.svg
  ```
