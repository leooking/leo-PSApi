class CreateOrgAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    create_table :org_asset_generators do |t|
      t.integer :org_id
      t.integer :asset_generator_id

      t.timestamps
    end
  end
end
