class CreateFolderGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :folder_groups do |t|
      t.integer :folder_id
      t.integer :group_id

      t.timestamps
    end
  end
end
