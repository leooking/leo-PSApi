class AddStartDateToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :start_date, :datetime
  end
end
