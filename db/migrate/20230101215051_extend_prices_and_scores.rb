class ExtendPricesAndScores < ActiveRecord::Migration[7.0]
  def change
    add_column :prices, :bid_reference, :string
    add_column :scores, :bid_reference, :string
  end
end
