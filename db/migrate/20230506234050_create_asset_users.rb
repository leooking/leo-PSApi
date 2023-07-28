class CreateAssetUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_users do |t|
      t.integer :asset_id
      t.integer :user_id

      t.timestamps
    end
  end
end
