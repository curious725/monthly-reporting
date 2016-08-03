class VacationRequest < ActiveRecord::Base
  belongs_to  :user
  has_many    :approval_requests, dependent: :destroy

  validates :end_date, :kind,
            :status, :start_date, :user,
            presence: true
  validates :end_date, :start_date,
            inclusion: { in: Date.new(2013, 9, 1)..Date.new(2050, 1, 1) }
  validate :cannot_intersect_with_other_vacations,
           unless: 'start_date.nil? || end_date.nil?'

  scope :requested_accepted_inprogress, lambda {
    where(status: [VacationRequest.statuses[:requested],
                   VacationRequest.statuses[:accepted],
                   VacationRequest.statuses[:inprogress]])
  }

  scope :not_cancelled_declined, lambda {
    where.not(status: [VacationRequest.statuses[:cancelled],
                       VacationRequest.statuses[:declined]])
  }

  scope :used, lambda {
    where(status: [VacationRequest.statuses[:used]])
  }

  scope :team_vacations, lambda { |team|
    joins(user: :team_roles)
      .where(team_roles: { team_id: team.id })
      .select(:id, :user_id, :kind, :status,
              :end_date, :start_date)
  }

  enum status: [
    :requested,
    :accepted,
    :declined,
    :cancelled,
    :inprogress,
    :used
  ]

  enum kind: [
    :planned,
    :unpaid,
    :sickness
  ]

  def cannot_intersect_with_other_vacations
    number_of_records = number_of_intersected_records

    errors.add(:base, 'Vacation cannot intersect with other vacations')\
      if number_of_records > 0
  end

  # Takes result of `Holiday.dates` as a parameter.
  # As the `Holiday.dates` hits DB, it is not good idea to use it here.
  def duration(holidays)
    vacation_range_duration - day_offs(holidays)
  end

  # TODO: apply algorithm to cannot_intersect_with_other_vacations()
  def overlaps?(another)
    (start_date - another.end_date) * (another.start_date - end_date) >= 0
  end

private

  def collection_of_holidays(holidays)
    (start_date..end_date).find_all do |date|
      holidays.include?(date)
    end
  end

  def collection_of_weekends
    (start_date..end_date).find_all do |date|
      date.saturday? || date.sunday?
    end
  end

  def day_offs(holidays)
    (collection_of_weekends + collection_of_holidays(holidays)).uniq.count
  end

  # Number of records that somehow intersect with the vacation.
  # For example, the vacation '2015-09-01'..'2015-09-10'
  # intersects with the following vacations:
  #   - '2015-09-01'..'2015-09-20', the vacation contains subject vacation
  #   - '2015-09-05'..'2015-09-15', by '2015-09-05'
  #   - '2015-08-25'..'2015-09-10', by '2015-09-10'
  #   - '2015-09-05'..'2015-09-09', subject vacation contains the vacation
  # NOTE: As of RoR 4 there is no way to compose SQL conditions
  #       with 'OR' operator, by using ActiveRecord.
  #       DHH promises to release this feature in RoR 5.
  #       But it is possible to solve the problem with Arel.
  #       https://github.com/rails/arel
  def number_of_intersected_records
    table = VacationRequest.arel_table

    VacationRequest.where(
      table[:start_date].between(start_date..end_date)
      .or(table[:end_date].between(start_date..end_date))
      .or(table[:start_date].lteq(start_date)
        .and(table[:end_date].gteq(end_date)))
    )
      .where(user_id: user_id)
      .where.not(id: id,
                 status: [
                   VacationRequest.statuses[:cancelled],
                   VacationRequest.statuses[:declined]]
                ).count
  end

  def vacation_range_duration
    (end_date - start_date).to_i + 1
  end
end
