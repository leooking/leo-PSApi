class AddMaxTokensToGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :max_tokens, :integer
  end
end
