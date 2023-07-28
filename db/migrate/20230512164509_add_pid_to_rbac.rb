class AddPidToRbac < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :pid, :string, null: false
    add_column :permissions, :pid, :string, null: false
  end
end
