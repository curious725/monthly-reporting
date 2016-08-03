class CreateVacationRequests < ActiveRecord::Migration
  def change
    create_table :vacation_requests do |t|
      t.string :type
      t.date :start
      t.date :end
      t.integer :duration
      t.string :status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
