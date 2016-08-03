class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user,
                only: [:update, :destroy, :available_vacations, :invite,
                       :requested_vacations, :vacation_approvals]

  rescue_from ActiveRecord::RecordNotFound do
    head status: :not_found
  end

  def index
    authorize User

    render json: policy_scope(User)
  end

  def create
    user = User.new user_params
    user.skip_password_validation = true
    authorize user
    if user.save
      render json: user
    else
      render json: { errors: user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    authorize @user
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    render json: {}, status: :no_content
  end

  def approval_requests
    authorize User
    requests = VacationRequest
      .joins(:approval_requests, :user)
      .where(approval_requests: { manager_id: params[:id] })
      .select('users.first_name', 'users.last_name', 'users.id as user_id',
              'approval_requests.id as id',
              :kind, :end_date, :start_date)

    render json: requests
  end

  def available_vacations
    authorize @user
    records = @user.available_vacations
    records.each(&:accumulate_more_days)

    render json: records
  end

  def invite
    authorize @user
    @user.invite!
    render json: @user
  end

  def requested_vacations
    authorize @user
    requests = @user.vacation_requests.requested
    render json: requests
  end

  def vacation_approvals
    authorize @user
    approval_requests = ApprovalRequest
      .joins(:vacation_request)
      .where(vacation_requests: { user_id: @user.id })

    render json: approval_requests
  end

private

  def user_params
    params
      .require(:user)
      .permit(:first_name,
              :last_name,
              :email,
              :birth_date,
              :employment_date)
  end

  def set_user
    @user = User.find_by!(id: params[:id])
  end
end
