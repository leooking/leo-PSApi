class CreateAssetGeneratorLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_generator_logs do |t|
      t.integer :asset_generator_id, null: false
      t.integer :asset_id, null: false
      t.integer :user_id, null: false
      t.jsonb :json_response, null: false

      t.timestamps
    end
  end
end
