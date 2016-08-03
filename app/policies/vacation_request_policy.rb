class VacationRequestPolicy < ApplicationPolicy
  def index?
    user
  end

  def create?
    manager_or_member?
  end

  def update?
    manager_or_member?
  end

  def approvers?
    member_who_owns_vacation?
  end

  def cancel?
    manager_or_member_who_owns_vacation?
  end

  def finish?
    manager_or_member_who_owns_vacation?
  end

  def start?
    manager_or_member_who_owns_vacation?
  end

private

  def manager_or_member?
    (user.manager? || user.member?)
  end

  def manager_or_member_who_owns_vacation?
    (user.manager? || user.member?) && user.owns_vacation_request?(record)
  end

  def member_who_owns_vacation?
    user.member? && user.owns_vacation_request?(record)
  end
end
