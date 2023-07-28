class MakeGeneratorTemperatureFloat < ActiveRecord::Migration[7.0]
  def up
    change_column :asset_generators, :temperature, :float, default: 0
  end
  def down
    change_column :asset_generators, :temperature, :integer, default: 0
  end
end
