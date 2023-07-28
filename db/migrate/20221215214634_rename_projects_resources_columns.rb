class RenameProjectsResourcesColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :projects, :type, :project_type
    rename_column :resources, :type, :resource_type
  end
end
