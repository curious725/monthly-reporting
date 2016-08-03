# The class encapsulates the following services:
#   - adding new users into DB,
#   - updating users in DB.
#
# A hash of the following attributes is required for a new instance:
#   - first_name
#   - last_name
#   - email
#   - birth_date
#   - employment_date
#   - password
# The hash attributes are mapped into appropriate original fields.
# For example:
# ```
# 'first_name' => 'Name'
# ```
#
# The service tries to create a record in DB.
# There following outcomes are possible:
#   - new user is added into DB,
#   - existing user is updated with provided data,
#   - fail due to errors.
#
# A new user is added into DB if there was no error during record
# creation DB transaction.
#
# A record creation DB transaction can fail. An error with
# the 'Email has already been taken' message is possible.
# In this case the existing user with given email is updated with provided data.
#
# In case of any other errors the service just reports about errors without
# any changes in DB.
class ImportUser
  EXPECTED_COLUMNS = {
    'first_name' => 'First Name',
    'last_name'  => 'Last Name',
    'email'      => 'Email',
    'birth_date' => 'Birth Day',
    'password'   => 'password',
    'employment_date' => 'Employment Date'
  }

  STATUSES = {
    new:      { short: 'o', verbose: 'NEW' },
    created:  { short: '+', verbose: 'CREATED' },
    updated:  { short: '.', verbose: 'UPDATED' },
    fail:     { short: 'x', verbose: 'FAIL' }
  }

  attr_reader :error

  def initialize(attributes, options = {})
    @options = { verbose: false }.merge(options)
    @attributes = attributes
    update_status(:new)
    @error = ''

    select_expected_attributes
    translate_attributes_keys
  end

  def insert_to_db
    insert_user
  rescue ActiveRecord::RecordInvalid => e
    if user_already_exists?(e)
      update_user
    else
      update_status(e.message)
    end
  rescue StandardError => e
    update_status(e.message)
  end

  def report
    @options[:verbose] ? report_verbose : report_with_symbol
  end

  def report_verbose
    message = format('%-8s', @status[:verbose])
    message += "#{@attributes['first_name']} #{@attributes['last_name']} "
      .squeeze(' ')
    message += "[#{@error}]" unless @error.empty?
    puts message.strip
  end

  def report_with_symbol
    print @status[:short]
  end

private

  def insert_user
    User.create!(@attributes)
    update_status(:created)
  end

  def select_expected_attributes
    @attributes.keep_if { |key| EXPECTED_COLUMNS.values.include?(key) }
  end

  def translate_attributes_keys
    EXPECTED_COLUMNS.each do |key, value|
      @attributes[key] = @attributes.delete(value) if EXPECTED_COLUMNS[key]
    end
  end

  def update_status(status, message = '')
    @status = STATUSES[status]
    @error = message
  end

  def update_user
    user = User.find_by(email: @attributes['email'])
    user.update_attributes(@attributes)
    errors = ''
    errors = user.errors.full_messages unless user.errors.empty?

    errors.empty? ? update_status(:updated) : update_status(:fail, errors)
  end

  def user_already_exists?(error)
    error.message =~ /Email has already been taken/
  end
end
