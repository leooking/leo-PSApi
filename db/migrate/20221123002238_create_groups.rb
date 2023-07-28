class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.integer :org_id
      t.string :name
      t.string :pid, null: false

      t.timestamps
    end
  end
end
