class RenameColumnEndInVacationRequestsToPlannedEndDate < ActiveRecord::Migration
  def change
    rename_column :vacation_requests, :end, :planned_end_date
  end
end
