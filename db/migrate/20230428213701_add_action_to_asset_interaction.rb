class AddActionToAssetInteraction < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :action, :string
  end
end
