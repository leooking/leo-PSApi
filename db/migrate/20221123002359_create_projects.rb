class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.integer :org_id
      t.integer :user_id
      t.string :type
      t.string :state
      t.string :name
      t.string :description
      t.string :objective
      t.string :pid, null: false

      t.timestamps
    end
  end
end
