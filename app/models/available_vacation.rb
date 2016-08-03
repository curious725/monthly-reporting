require 'available_vacations/calculus'

include AvailableVacations

class AvailableVacation < ActiveRecord::Base
  belongs_to :user

  validates :available_days, :kind, :user_id,
            presence: true
  validates :user_id,
            uniqueness: { scope: :kind,
                          message: 'already has this type of limit' }
  validates :available_days,
            numericality: { only_float: true,
                            greater_than: 0 }

  validates_associated :user

  enum kind: [
    :planned,
    :unpaid,
    :sickness
  ]

  def accumulate_more_days
    diff_in_days = days_since_last_update
    to_be_upadted = (diff_in_days > 0 && kind != 'unpaid')
    if to_be_upadted
      days = diff_in_days * AvailableVacations::RATES[kind.to_sym]
      update_attribute(:available_days, available_days + days)
    end
  end

private

  def days_since_last_update
    Time.zone.today - updated_at.to_date
  end
end
