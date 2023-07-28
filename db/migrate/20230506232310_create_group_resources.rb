class CreateGroupResources < ActiveRecord::Migration[7.0]
  def change
    create_table :group_resources do |t|
      t.integer :group_id
      t.integer :resource_id

      t.timestamps
    end
  end
end
