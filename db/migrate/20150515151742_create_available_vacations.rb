class CreateAvailableVacations < ActiveRecord::Migration
  def change
    create_table :available_vacations do |t|
      t.string :type
      t.float :available_days
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
