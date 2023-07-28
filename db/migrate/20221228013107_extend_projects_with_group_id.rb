class ExtendProjectsWithGroupId < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :group_id, :integer
  end
end
