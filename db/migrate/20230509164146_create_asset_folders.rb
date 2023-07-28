class CreateAssetFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_folders do |t|
      t.integer :asset_id
      t.integer :folder_id

      t.timestamps
    end
  end
end
