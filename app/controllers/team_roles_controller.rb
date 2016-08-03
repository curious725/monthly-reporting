class TeamRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team_role, only: [:destroy]

  rescue_from ActiveRecord::RecordNotFound do
    head status: :not_found
  end

  def index
    render json: TeamRole.select(:id, :role, :user_id, :team_id)
  end

  def create
    team_role = TeamRole.new team_role_params
    authorize team_role
    if team_role.save
      render json: team_role
    else
      render json: { errors: team_role.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    authorize @team_role
    @team_role.destroy
    render json: {}, status: :no_content
  end

private

  def team_role_params
    params.require(:team_role).permit(:role, :team_id, :user_id)
  end

  def set_team_role
    @team_role = TeamRole.find_by!(id: params[:id])
  end
end
