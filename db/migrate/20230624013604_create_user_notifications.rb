class CreateUserNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :user_notifications do |t|
      t.string :message
      t.string :message_type
      t.integer :user_id
      t.boolean :read
      t.string :pid, null:false

      t.timestamps
    end
  end
end
