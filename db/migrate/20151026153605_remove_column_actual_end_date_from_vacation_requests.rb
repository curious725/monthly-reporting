class RemoveColumnActualEndDateFromVacationRequests < ActiveRecord::Migration
  def change
    remove_column :vacation_requests, :actual_end_date
  end
end
