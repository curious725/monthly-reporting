class ChangeKindInVacationRequests < ActiveRecord::Migration
  def up
    change_column :vacation_requests, :kind, :integer, default: 0
  end

  def down
    change_column :vacation_requests, :kind, :string
  end
end
