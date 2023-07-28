class ChangePidToAssetRevisions < ActiveRecord::Migration[7.0]
  def change
    change_column :asset_revisions, :pid, :string, null: false
  end
end