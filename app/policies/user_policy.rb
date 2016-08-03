class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope
          .joins(:team_roles)
          .where(team_roles: { team_id: user.teams.ids.uniq })
          .uniq
      end
    end
  end

  def index?
    user
  end

  def create?
    user && user.admin?
  end

  def update?
    user && user.admin?
  end

  def destroy?
    user && user.admin?
  end

  def approval_requests?
    user
  end

  def available_vacations?
    user
  end

  def invite?
    user && user.admin?
  end

  def requested_vacations?
    user
  end

  def vacation_approvals?
    user && (user.member? || user.admin?)
  end
end
