class Add3rdPartyToAssetInteraction < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :third_party_data, :jsonb, default: {}
  end
end
