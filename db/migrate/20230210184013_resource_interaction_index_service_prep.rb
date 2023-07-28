class ResourceInteractionIndexServicePrep < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :raw_text, :text
    add_column :asset_interactions, :resource_data, :jsonb
    add_column :asset_interactions, :citation_data, :jsonb

  end
end
