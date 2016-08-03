class ChangeStatusInVacationRequests < ActiveRecord::Migration
  def up
    change_column :vacation_requests, :status, :integer, default: 0
  end

  def down
    change_column :vacation_requests, :status, :string
  end
end
