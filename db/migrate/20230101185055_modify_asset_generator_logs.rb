class ModifyAssetGeneratorLogs < ActiveRecord::Migration[7.0]
  def change
    rename_column :asset_generator_logs, :asset_id, :loggable_id
    rename_column :asset_generator_logs, :status, :http_status
    add_column :asset_generator_logs, :loggable_type, :string, null: false, default: ''
    add_column :asset_generator_logs, :expense, :string
  end
end
