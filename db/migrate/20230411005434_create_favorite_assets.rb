class CreateFavoriteAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_assets do |t|
      t.integer :user_id
      t.integer :asset_id

      t.timestamps
    end
  end
end
