class ExtendAssetGeneratorsWithSampleResponse < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :sample_response, :jsonb
  end
end
