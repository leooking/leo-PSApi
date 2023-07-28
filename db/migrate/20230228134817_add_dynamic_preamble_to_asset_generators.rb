class AddDynamicPreambleToAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :dynamic_preamble, :text
  end
end
