class ExtendAssetGeneratorForConvo < ActiveRecord::Migration[7.0]
  def change
    add_column    :asset_generators, :convo_preface,        :text
    add_column    :asset_generators, :sidebar_instruction,  :text
    rename_column :asset_generators, :user_instruction, :asset_instruction
  end
end
