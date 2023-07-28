class AddTemperatureToGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :temperature, :integer
  end
end
