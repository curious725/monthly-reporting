class ApprovalRequest < ActiveRecord::Base
  belongs_to  :vacation_request
  belongs_to  :user, foreign_key: :manager_id

  validates :manager_id, :vacation_request_id,
            presence: true
  validates :vacation_request_id,
            uniqueness: { scope: :user,
                          message: 'is already assigned to this mamager' }

  def as_json(options)
    options[:only] = [
      :id,
      :manager_id,
      :vacation_request_id
    ]

    super options
  end
end
