class RenameColumnStartInVacationRequestsToStartDate < ActiveRecord::Migration
  def change
    rename_column :vacation_requests, :start, :start_date
  end
end
