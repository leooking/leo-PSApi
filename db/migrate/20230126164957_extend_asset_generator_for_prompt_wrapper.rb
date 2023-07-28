class ExtendAssetGeneratorForPromptWrapper < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :before_prompt, :text
    add_column :asset_generators, :after_prompt,  :text
    add_column :asset_generators, :version, :string
  end
end
