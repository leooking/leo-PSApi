class AddEmbeddingToResources < ActiveRecord::Migration[7.0]
  def change
    add_column  :resources, :embedding, :jsonb, default: {}
  end
end
