class ChangeUserDashboardHomeBooleanDefault < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :dashboard_home, :boolean, default: true
  end
  def down
    change_column :users, :dashboard_home, :boolean, default: false
  end
end
