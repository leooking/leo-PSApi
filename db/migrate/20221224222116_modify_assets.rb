class ModifyAssets < ActiveRecord::Migration[7.0]
  def up
    change_column :assets, :input, :text
    rename_column :assets, :input, :prompt
    rename_column :assets, :text, :result
    add_column    :assets, :objective, :string
    add_column    :assets, :asset_generator_id, :integer
  end
  def down
    remove_column :assets, :asset_generator_id, :integer
    remove_column :assets, :objective, :string
    rename_column :assets, :result, :text
    rename_column :assets, :prompt, :input
    change_column :assets, :input, :string
  end
end
