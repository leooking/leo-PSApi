class CreateAssetArtifacts < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_artifacts do |t|
      t.binary :blob
      t.text :plain_text
      t.integer :asset_id
      t.integer :user_id

      t.timestamps
    end
  end
end
