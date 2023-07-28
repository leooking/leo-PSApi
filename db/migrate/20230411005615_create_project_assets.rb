class CreateProjectAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :project_assets do |t|
      t.integer :project_id
      t.integer :asset_id

      t.timestamps
    end
  end
end
