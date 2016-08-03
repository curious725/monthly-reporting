class RenameTypeInAvailableVacation < ActiveRecord::Migration
  def up
    rename_column :available_vacations, :type, :kind
  end

  def down
    rename_column :available_vacations, :kind, :type
  end
end
