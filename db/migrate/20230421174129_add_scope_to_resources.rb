class AddScopeToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :scope, :string, default: 'org'
  end
end
