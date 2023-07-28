class AddPromptAssistToAssetGenerator < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_generators, :prompt_assistant_visible, :boolean, default: false
  end
end
