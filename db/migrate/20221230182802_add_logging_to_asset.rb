class AddLoggingToAsset < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :asset_generator_log_id, :integer
  end
end
