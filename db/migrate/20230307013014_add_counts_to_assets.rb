class AddCountsToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :total_tokens, :integer
  end
end
