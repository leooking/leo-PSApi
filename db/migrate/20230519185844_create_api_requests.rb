class CreateApiRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :api_requests do |t|
      t.string :name
      t.string :description
      t.string :notes
      t.jsonb :request_json
      t.string :endpoint
      t.string :pid, null: false

      t.timestamps
    end
  end
end
