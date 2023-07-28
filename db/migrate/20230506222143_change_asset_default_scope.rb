class ChangeAssetDefaultScope < ActiveRecord::Migration[7.0]
  def change
    change_column_default :assets, :scope, from: 'me', to: 'org' 
  end
end
