class CreateAssetGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_groups do |t|
      t.integer :asset_id
      t.integer :group_id

      t.timestamps
    end
  end
end
