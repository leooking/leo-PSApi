class CreateApiResults < ActiveRecord::Migration[7.0]
  def change
    create_table :api_results do |t|
      t.integer :api_call_id, null: false
      t.jsonb :json_response
      t.string :pid, null: false

      t.timestamps
    end
  end
end
