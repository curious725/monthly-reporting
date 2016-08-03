class HolidaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_holiday, only: [:update, :destroy]

  rescue_from ActiveRecord::RecordNotFound do
    head status: :not_found
  end

  def index
    render json: Holiday
      .select(:id, :description, :duration, :start)
      .all
  end

  def create
    holiday = Holiday.new holiday_params
    authorize holiday
    if holiday.save
      render json: holiday
    else
      render  json: { errors: holiday.errors },
              status: :unprocessable_entity
    end
  end

  def update
    authorize @holiday
    if @holiday.update(holiday_params)
      head status: :no_content
    else
      render  json: { errors: @holiday.errors },
              status: :unprocessable_entity
    end
  end

  def destroy
    authorize @holiday
    @holiday.destroy
    head status: :no_content
  end

private

  def holiday_params
    params.require(:holiday).permit(:description, :duration, :start)
  end

  def set_holiday
    @holiday = Holiday.find_by!(id: params[:id])
  end
end
