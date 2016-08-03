class RenameColumnPlannedEndDateInVacationRequests < ActiveRecord::Migration
  def change
    rename_column :vacation_requests, :planned_end_date, :end_date
  end
end
