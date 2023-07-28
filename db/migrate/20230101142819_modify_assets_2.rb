class ModifyAssets2 < ActiveRecord::Migration[7.0]
  def change
    remove_column :assets, :prompt, :text
    remove_column :assets, :result, :text
  end
end
