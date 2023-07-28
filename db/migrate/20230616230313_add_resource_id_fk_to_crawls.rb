class AddResourceIdFkToCrawls < ActiveRecord::Migration[7.0]
  def change
    add_column :crawls, :resource_id, :integer
  end
end
