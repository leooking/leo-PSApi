class CreateAssetRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_revisions do |t|
      t.integer :asset_id, null: false
      t.integer :asset_generator_id, null: false
      t.integer :project_id
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
