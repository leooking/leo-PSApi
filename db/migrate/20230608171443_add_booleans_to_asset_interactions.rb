class AddBooleansToAssetInteractions < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :use_my_resources, :boolean, default: false
    add_column :asset_interactions, :use_ext_resources, :boolean, default: false
    add_column :asset_interactions, :use_premium_resources, :boolean, default: false
  end
end
