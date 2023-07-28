class FixAssetGeneratorLogsPrimaryKey < ActiveRecord::Migration[7.0]
  def change
    remove_column :asset_generator_logs, :id, :integer
    add_column :asset_generator_logs, :id, :primary_key
  end
end
