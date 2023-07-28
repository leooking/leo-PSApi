class AddToggleBooleansToGenerators < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :my_resources_visible, :boolean, default: false
    add_column  :asset_generators, :ext_resources_visible, :boolean, default: false
  end
end
