class AddCosineThresholdToAssetInteractions < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :cosine_threshold, :float
  end
end
