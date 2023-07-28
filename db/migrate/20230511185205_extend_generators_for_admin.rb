class ExtendGeneratorsForAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :global_preamble_default, :string
    add_column :asset_generators, :global_preamble_1st_party, :string
    add_column :asset_generators, :global_preamble_3rd_party, :string
    add_column :asset_generators, :custom_preambles_3rd_party, :jsonb
    add_column :asset_generators, :global_temp_1st_party, :float
    add_column :asset_generators, :global_temp_3rd_party, :float
    add_column :asset_generators, :custom_temps_3rd_party, :jsonb
    add_column :asset_generators, :action_specific_preambles, :jsonb
  end
end
