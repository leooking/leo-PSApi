class RenameGeneratorColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :asset_generators, :before_prompt, :preamble
    rename_column :asset_generators, :after_prompt, :response_trigger
  end
end
