require 'errors/conflict_error'

class VacationRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vacation_request,
                only: [:show, :update, :approvers, :cancel, :finish, :start]

  after_action  :update_available_vacations!,
                only: [:index, :finish]
  rescue_from ActiveRecord::RecordNotFound do
    head status: :not_found
  end

  rescue_from Errors::ConflictError do
    head status: :conflict
  end

  def index
    render json: current_user.vacation_requests
      .select(:id, :kind, :status, :start_date, :end_date, :user_id)
  end

  def create
    @vacation_request = current_user
      .vacation_requests.new vacation_request_params

    authorize @vacation_request
    managers_ids = current_user.list_of_assigned_managers_ids

    set_allowed_values!
    change_status!(managers_ids)

    if @vacation_request.save && create_approval_request(managers_ids)
      render  status: :created,
              json: @vacation_request
    else
      render  status: :unprocessable_entity,
              json: { errors: @vacation_request.errors.full_messages }
    end
  end

  # TODO: check if the action method below is needed
  # it seems that is was implemented rather by convection, not by need.
  def show
    render json: @vacation_request
  end

  def update
    if @vacation_request.update(vacation_request_params)
      head  status: :no_content
    else
      head  status: :not_found
    end
  end

  def approvers
    authorize @vacation_request

    users = User
      .joins(:approval_requests)
      .where(approval_requests: { vacation_request_id: @vacation_request[:id] })
      .select(:id, :first_name, :last_name)

    render json: users
  end

  def cancel
    authorize @vacation_request
    check_status_for_cancel
    @vacation_request.update!(status: VacationRequest.statuses[:cancelled])
    @vacation_request.approval_requests.destroy_all

    render json: @vacation_request
  end

  def finish
    authorize @vacation_request
    check_status_for_finish
    @vacation_request.update!(status: VacationRequest.statuses[:used])

    render json: @vacation_request
  end

  def start
    authorize @vacation_request
    check_status_for_start
    @vacation_request.update!(status: VacationRequest.statuses[:inprogress])

    render json: @vacation_request
  end

private

  def create_approval_request(managers_ids)
    return true if @vacation_request.status == 'accepted'

    records = managers_ids.map do |id|
      { manager_id: id, vacation_request_id: @vacation_request.id }
    end
    ApprovalRequest.create records
  end

  def change_status!(managers_ids)
    @vacation_request.status = 'accepted' if managers_ids.empty?
  end

  def check_status_for_cancel
    status = @vacation_request.status
    allowed_status = (status == 'requested' || status == 'accepted')
    fail Errors::ConflictError unless allowed_status
  end

  def check_status_for_finish
    fail Errors::ConflictError unless @vacation_request.status == 'inprogress'
  end

  def check_status_for_start
    fail Errors::ConflictError unless @vacation_request.status == 'accepted'
  end

  def set_allowed_values!
    @vacation_request.status = 'requested'
  end

  def set_vacation_request
    @vacation_request = VacationRequest.find_by!(id: params[:id])
  end

  def update_available_vacations!
    return unless @vacation_request

    kind = @vacation_request.kind
    used = current_user.used_days(kind)
    accumulated = current_user.accumulated_days(kind)

    current_user.available_vacations.find_by!(kind: kind)
      .update_attribute(:available_days, accumulated - used)
  end

  def vacation_request_params
    params.require(:vacation_request)
      .permit(:kind, :status, :start_date, :end_date)
  end
end
