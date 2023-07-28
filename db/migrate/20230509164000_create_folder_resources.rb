class CreateFolderResources < ActiveRecord::Migration[7.0]
  def change
    create_table :folder_resources do |t|
      t.integer :folder_id
      t.integer :resource_id

      t.timestamps
    end
  end
end
