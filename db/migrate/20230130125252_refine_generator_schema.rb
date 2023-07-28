class RefineGeneratorSchema < ActiveRecord::Migration[7.0]
  def change
    remove_column :asset_generators, :prompt_key, :string
  end
end
