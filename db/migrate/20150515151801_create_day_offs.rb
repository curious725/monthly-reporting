class CreateDayOffs < ActiveRecord::Migration
  def change
    create_table :day_offs do |t|
      t.string :description
      t.date :start
      t.integer :duration

      t.timestamps null: false
    end
  end
end
