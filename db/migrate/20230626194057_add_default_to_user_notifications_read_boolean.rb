class AddDefaultToUserNotificationsReadBoolean < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_notifications, :read, from: nil, to: false
  end
end
