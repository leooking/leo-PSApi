class CreateAssetInteractions < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_interactions do |t|
      t.string :custom_settings
      t.text :prompt
      t.text :response
      t.string :http_status
      t.integer :asset_id, null: false
      t.integer :asset_generator_id, null: false
      t.integer :project_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
