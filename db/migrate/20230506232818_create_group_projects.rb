class CreateGroupProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :group_projects do |t|
      t.integer :group_id
      t.integer :project_id

      t.timestamps
    end
  end
end
