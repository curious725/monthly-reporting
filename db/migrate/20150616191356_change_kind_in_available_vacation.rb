class ChangeKindInAvailableVacation < ActiveRecord::Migration
  def up
    change_column :available_vacations, :kind, :integer, default: 0
  end

  def down
    change_column :available_vacations, :kind, :string
  end
end
