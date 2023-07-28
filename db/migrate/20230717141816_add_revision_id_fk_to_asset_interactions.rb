class AddRevisionIdFkToAssetInteractions < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_interactions, :asset_revision_id, :integer
  end
end