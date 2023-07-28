class AddingBasicIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :asset_interactions, :asset_id
    add_index :asset_interactions, :asset_generator_id
    add_index :asset_folders, :asset_id
    add_index :asset_folders, :folder_id
    add_index :folder_resources, :folder_id
    add_index :folder_projects, :folder_id
    add_index :folders, :parent_id
    add_index :folders, :user_id
    add_index :folders, :folder_type
    add_index :resources, :user_id
    add_index :assets, :user_id
    add_index :projects, :user_id
    add_index :assets, :scope
    add_index :folders, :scope
    add_index :projects, :scope
    add_index :resources, :scope
  end
end
