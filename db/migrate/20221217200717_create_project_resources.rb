class CreateProjectResources < ActiveRecord::Migration[7.0]
  def up
    create_table :project_resources do |t|
      t.integer :project_id
      t.integer :resource_id

      t.timestamps
    end
    remove_column :resources, :project_id
  end
  def down
    add_column :resources, :project_id, :integer
    drop_table :project_resources
  end
end
