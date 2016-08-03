class AddColumnToVacationRequests < ActiveRecord::Migration
  def change
    add_column :vacation_requests, :actual_end_date, :date
  end
end
