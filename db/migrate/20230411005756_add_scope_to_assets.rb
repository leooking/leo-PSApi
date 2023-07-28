class AddScopeToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :scope, :string, default: 'me'
  end
end
