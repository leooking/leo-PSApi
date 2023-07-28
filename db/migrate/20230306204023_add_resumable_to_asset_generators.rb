class AddResumableToAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :resumable, :boolean, default: false
  end
end
