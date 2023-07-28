class AddTokenCostToAssetInteractions < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_interactions, :token_cost, :integer
  end
end
