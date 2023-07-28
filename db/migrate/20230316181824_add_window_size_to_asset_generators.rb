class AddWindowSizeToAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :window_size, :integer
  end
end
