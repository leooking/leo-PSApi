class AddActiveToGroupUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :group_users, :active, :boolean, default: false
  end
end
