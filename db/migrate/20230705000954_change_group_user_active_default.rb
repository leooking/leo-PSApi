class ChangeGroupUserActiveDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :group_users, :active, from: false, to: true
  end
end

