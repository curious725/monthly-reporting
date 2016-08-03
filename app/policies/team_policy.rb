class TeamPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.select(:id, :name).uniq
      else
        user.teams.select(:id, :name).uniq
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
end
