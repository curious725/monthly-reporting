class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.date :birth_date
      t.string :username

      t.timestamps null: false
    end
    add_index :users, :username, unique: true
  end
end
