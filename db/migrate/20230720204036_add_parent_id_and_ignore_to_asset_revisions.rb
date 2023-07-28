class AddParentIdAndIgnoreToAssetRevisions < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_revisions, :parent_id, :integer
    add_column :asset_revisions, :ignore, :boolean, default: false
  end
end