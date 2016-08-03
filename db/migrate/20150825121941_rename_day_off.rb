class RenameDayOff < ActiveRecord::Migration
  def self.up
    rename_table :day_offs, :holidays
  end

  def self.down
    rename_table :holidays, :day_offs
  end
end
