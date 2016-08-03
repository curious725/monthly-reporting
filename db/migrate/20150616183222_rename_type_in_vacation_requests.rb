class RenameTypeInVacationRequests < ActiveRecord::Migration
  def up
    change_table :vacation_requests do |t|
      t.rename :type, :kind
    end
  end

  def down
    change_table :vacation_requests do |t|
      t.rename :kind, :type
    end
  end
end
