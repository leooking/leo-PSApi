class AddScopeToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :scope, :string, default: 'org'
  end
end
