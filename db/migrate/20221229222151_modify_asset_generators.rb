class ModifyAssetGenerators < ActiveRecord::Migration[7.0]
  def up
    change_column :asset_generators, :description, :text
    rename_column :asset_generators, :description, :info
  end
  def down
    rename_column :asset_generators, :info, :description
    change_column :asset_generators, :description, :string
  end
end
