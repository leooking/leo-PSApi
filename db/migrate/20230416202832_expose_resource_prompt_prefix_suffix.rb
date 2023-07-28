class ExposeResourcePromptPrefixSuffix < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :resource_instructions_prefix, :text
    add_column  :asset_generators, :resource_instructions_suffix, :text
  end
end
