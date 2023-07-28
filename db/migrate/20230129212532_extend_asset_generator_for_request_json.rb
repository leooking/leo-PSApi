class ExtendAssetGeneratorForRequestJson < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :request_json, :jsonb
    add_column :asset_generators, :prompt_key, :string
  end
end
