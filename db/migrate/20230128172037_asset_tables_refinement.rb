class AssetTablesRefinement < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :pid, :string
    add_column :asset_interactions, :thumbs, :boolean # nil until used
    remove_column :assets, :asset_generator_log_id, :integer # deprecated for loggable
  end
end
