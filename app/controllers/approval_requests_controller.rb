# Normally, each vacation request has approval request assigned to a manager.
# When approval request is accepted, it is deleted from DB.
# When vacation request has no approval requests, it changes its status
# from 'requested' to 'accepted'.
# Approval request can be declined. In this case all the approval requests
# are deleted from DB, and status of the associated vacation request
# is set to 'declined'.
# Only managers are authorized to operate on approval requests.
require 'errors/conflict_error'

class ApprovalRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_approval_request, only: [:accept, :decline]
  before_action :check_vacation_request_status, only: [:accept, :decline]

  after_action :verify_authorized, except: :index

  rescue_from ActiveRecord::RecordNotFound do
    head status: :not_found
  end

  rescue_from Errors::ConflictError do
    head status: :conflict
  end

  def index
    render json: policy_scope(ApprovalRequest)
  end

  def accept
    authorize @approval_request
    status = VacationRequest.statuses[:accepted]
    change_vacation_request_status(status) if approval_request_count == 1
    @approval_request.destroy
    render status: :ok, json: {}
  end

  def decline
    authorize @approval_request
    status = VacationRequest.statuses[:declined]
    change_vacation_request_status(status)
    @approval_request.vacation_request.approval_requests.destroy_all
    render status: :ok, json: {}
  end

private

  def approval_request_count
    @approval_request.vacation_request.approval_requests.count
  end

  def change_vacation_request_status(status)
    vacation_request = @approval_request.vacation_request
    vacation_request.status = status
    vacation_request.save!
  end

  def check_vacation_request_status
    status = @approval_request.vacation_request.status
    fail Errors::ConflictError if status != 'requested'
  end

  def set_approval_request
    @approval_request = ApprovalRequest.find_by!(id: params[:id])
  end
end
