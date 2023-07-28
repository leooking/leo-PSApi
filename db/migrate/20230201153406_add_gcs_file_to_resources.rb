class AddGcsFileToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :gcs_file, :string
    remove_column :resources, :data_asset, :string
    add_column :resources, :data_asset, :jsonb
  end
end
