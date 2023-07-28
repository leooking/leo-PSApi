class AddToggleConfigToGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :toggle_config, :jsonb, default: {my_resources: false, ext_resources: false}
  end
end
