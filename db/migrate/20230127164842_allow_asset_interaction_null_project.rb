class AllowAssetInteractionNullProject < ActiveRecord::Migration[7.0]
  def change
    change_column_null :asset_interactions, :project_id, true
  end
end
