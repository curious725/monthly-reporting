class ChangeStatusInVacationRequests < ActiveRecord::Migration
  def up
    change_column :vacation_requests, :status, :integer
    change_column_default :vacation_requests, :status, 0
  end

  def down
    change_column :vacation_requests, :status, :string
  end
end
