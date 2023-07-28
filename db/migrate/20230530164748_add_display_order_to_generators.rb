class AddDisplayOrderToGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :display_order, :float
  end
end
