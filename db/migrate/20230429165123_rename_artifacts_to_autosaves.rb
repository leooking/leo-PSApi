class RenameArtifactsToAutosaves < ActiveRecord::Migration[7.0]
  def change
    rename_table :asset_artifacts, :asset_autosaves
  end
end
