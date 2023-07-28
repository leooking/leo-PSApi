class CreateHookLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :hook_logs do |t|
      t.jsonb :raw_event
      t.string :customer_id
      t.string :event_id
      t.string :event_type
      t.integer :org_id

      t.timestamps
    end
  end
end