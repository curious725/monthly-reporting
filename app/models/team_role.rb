class TeamRole < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :team

  scope :admins, lambda {
    where(role: TeamRole.roles[:admin])
  }

  scope :managers, lambda {
    where(role: TeamRole.roles[:manager])
  }

  scope :members, lambda {
    where(role: TeamRole.roles[:member])
  }

  scope :guests, lambda {
    where(role: TeamRole.roles[:guest])
  }

  validates :role,    presence: true
  validates :team_id, presence: true
  validates :user_id,
            presence: true,
            uniqueness: { scope: [:role, :team],
                          message: 'already has this role in the team' }

  validates_associated :user
  validates_associated :team

  enum role: [
    :guest,
    :member,
    :manager,
    :admin
  ]
end
