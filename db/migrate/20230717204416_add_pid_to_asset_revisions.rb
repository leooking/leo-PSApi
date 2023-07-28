class AddPidToAssetRevisions < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_revisions, :pid, :integer, null: false
  end
end