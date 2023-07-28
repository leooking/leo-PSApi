class CreateAllocations < ActiveRecord::Migration[7.0]
  def change
    create_table :allocations do |t|
      t.integer :org_id
      t.integer :license_id
      t.integer :user_id

      t.timestamps
    end
  end
end
