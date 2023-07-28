class AddPromptBuilderToAssetGenerator < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :prompt_builder_visible, :boolean, default: false
  end
end
