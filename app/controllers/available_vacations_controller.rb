class AvailableVacationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @records = AvailableVacation.all
      .select(:id, :kind, :available_days, :user_id, :updated_at)

    @records.each(&:accumulate_more_days)
    render json: @records
  end
end
