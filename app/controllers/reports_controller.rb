class ReportsController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  
  def index
     render json: current_user.reports
    #render text: Report.to_csv(current_user.id)
  end

  def download_report
    respond_to do |format|
      format.json { render json: current_user.reports.to_a }
      format.csv { render text: Report.to_csv(current_user.id) }
    end
  end

  def download_reports
    render text: Report.to_csv
  end

  def show
    render json: @report
  end

  def new
    #@report = Report.new
  end

  def edit
  end

  def create
    @report = current_user.reports.new(report_params)

      if @report.save
        render status: :created, json: @report
      else
        render status: :unprocessable_entity,
               json: { errors: @report.errors.full_messages }
      end
      
  end

  def update
      if @report.update(report_params)
        render status: :ok, json: @report
      else
        render status: :unprocessable_entity,
               json: { errors: @report.errors.full_messages }
      end
  end

  def destroy
    @report.destroy
    render json: {}, status: :no_content
  end

  private
    def set_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.require(:report).permit(:body, :user_id)
    end
end
