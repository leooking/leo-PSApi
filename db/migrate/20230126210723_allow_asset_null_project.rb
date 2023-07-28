class AllowAssetNullProject < ActiveRecord::Migration[7.0]
  def change
    change_column_null :assets, :project_id, true
  end
end
