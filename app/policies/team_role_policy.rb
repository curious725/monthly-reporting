class TeamRolePolicy < ApplicationPolicy
  def index?
    user
  end

  def create?
    user && user.admin?
  end

  def destroy?
    user && user.admin?
  end
end
