class RemoveColumnFromVacationRequests < ActiveRecord::Migration
  def change
    remove_column :vacation_requests, :duration, :string
  end
end
