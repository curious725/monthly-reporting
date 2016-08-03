# Only users with manager role can accept or decline approval requests, which
# were assigned to them after vacation request creation by a team-mate.
class ApprovalRequestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.approval_requests
      end
    end
  end

  def index?
    user
  end

  def accept?
    user.manager_of_user?(record.vacation_request.user) &&
      user.approval_requests.ids.include?(record.id)
  end

  def decline?
    user.manager_of_user?(record.vacation_request.user) &&
      user.approval_requests.ids.include?(record.id)
  end
end
