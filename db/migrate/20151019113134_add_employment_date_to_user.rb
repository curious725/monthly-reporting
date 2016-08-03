class AddEmploymentDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :employment_date, :date
  end
end
