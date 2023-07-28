class RenameRbacTables < ActiveRecord::Migration[7.0]
  def change
    rename_table :user_roles, :role_users
    rename_table :role_permissions, :permission_roles
  end
end
