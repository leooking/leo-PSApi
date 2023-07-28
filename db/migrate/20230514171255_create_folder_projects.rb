class CreateFolderProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :folder_projects do |t|
      t.integer :folder_id
      t.integer :project_id

      t.timestamps
    end
  end
end
