class ExtendUserProfileDashboard < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dashboard_home, :boolean, default: false
  end
end
