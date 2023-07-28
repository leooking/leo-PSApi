class CreateAssetOrgs < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_orgs do |t|
      t.integer :asset_id
      t.integer :org_id

      t.timestamps
    end
  end
end
