class AddFrozenToAsset < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :frozen, :boolean, default: false
  end
end
