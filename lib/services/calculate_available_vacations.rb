# The class encapsulates service for calculating available vacations
# of each type for given user and saving results into DB.
#
# The service tries to create a record in DB.
# There following outcomes are possible:
#   - new record is added into DB,
#   - fail due to errors.
#
# A new record is added into DB if there was no error during record
# creation DB transaction.
#
# A record creation DB transaction can fail. In case of any errors the service
# just reports about errors without any changes in DB.
class CalculateAvailableVacations
  STATUSES = {
    new:      { short: 'o', verbose: 'NEW' },
    created:  { short: '+', verbose: 'CREATED' },
    fail:     { short: 'x', verbose: 'FAIL' }
  }

  def initialize(user, options = {})
    @data = {}
    @error = ''
    @options = { verbose: false }.merge(options)
    @status = STATUSES[:new]
    @user = user
  end

  def run
    prepare_data
    insert_records
  end

private

  def insert_records
    AvailableVacation.kinds.keys.each do |kind|
      @kind = kind
      insert_record
    end
  end

  def prepare_data
    attributes = {}
    attributes[:user_id] = @user.id
    days = @user.accumulated_days_of_all_types

    AvailableVacation.kinds.keys.each do |kind|
      attributes[:kind] = AvailableVacation.kinds[kind]
      attributes[:available_days] = days[kind.to_sym]
      @data[kind] = attributes.clone
    end
  end

  def insert_record
    AvailableVacation.create! @data[@kind]
    @status = STATUSES[:created]
  rescue StandardError => e
    update_status(e)
  ensure
    report
  end

  def report
    @options[:verbose] ? report_verbose : report_with_symbol
  end

  def report_verbose
    message = format('%-8s', @status[:verbose])
    message += "#{@user['first_name']} #{@user['last_name']} "
      .squeeze(' ')
    message += "[#{@kind}, #{@error}]" unless @error.empty?
    message += "[#{@kind}]" if @error.empty?
    puts message.strip
  end

  def report_with_symbol
    print @status[:short]
  end

  def update_status(error)
    @status = STATUSES[:fail]
    @error = error.message
  end
end
