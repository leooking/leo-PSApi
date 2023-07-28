class ExtendAssetGeneratorForShowcase < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :home_showcase, :boolean, default: false
  end
end
