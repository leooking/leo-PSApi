class DefaultScopeToGroup < ActiveRecord::Migration[7.0]
  def change
    change_column_default :assets, :scope, from: 'org', to: 'group'
    change_column_default :folders, :scope, from: 'org', to: 'group'
    change_column_default :prompts, :scope, from: 'org', to: 'group'
    change_column_default :projects, :scope, from: 'org', to: 'group'
    change_column_default :resources, :scope, from: 'org', to: 'group'
  end
end
