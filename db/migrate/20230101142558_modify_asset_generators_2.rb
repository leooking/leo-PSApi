class ModifyAssetGenerators2 < ActiveRecord::Migration[7.0]
  def change
    rename_column :asset_generators, :info, :user_instruction
    add_column :asset_generators, :pricing_tier, :string
    add_column :asset_generators, :card_description, :string
    add_column :asset_generators, :internal_notes, :string
  end
end
