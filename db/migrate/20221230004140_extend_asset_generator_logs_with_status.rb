class ExtendAssetGeneratorLogsWithStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generator_logs, :status, :string
  end
end
