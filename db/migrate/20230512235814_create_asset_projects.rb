class CreateAssetProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_projects do |t|
      t.integer :asset_id
      t.integer :project_id

      t.timestamps
    end
  end
end
