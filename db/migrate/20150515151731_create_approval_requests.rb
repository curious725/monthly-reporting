class CreateApprovalRequests < ActiveRecord::Migration
  def change
    create_table :approval_requests do |t|
      t.integer :manager_id
      t.references :vacation_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
