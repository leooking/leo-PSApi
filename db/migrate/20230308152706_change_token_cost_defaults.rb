class ChangeTokenCostDefaults < ActiveRecord::Migration[7.0]
  def change
    change_column_default :assets, :total_tokens, from: nil, to: 0
    change_column_default :asset_interactions, :token_cost, from: nil, to: 0
  end
end
