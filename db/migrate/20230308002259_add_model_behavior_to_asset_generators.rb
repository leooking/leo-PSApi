class AddModelBehaviorToAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :model_behavior, :string
  end
end
