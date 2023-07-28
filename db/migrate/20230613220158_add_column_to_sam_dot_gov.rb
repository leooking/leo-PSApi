class AddColumnToSamDotGov < ActiveRecord::Migration[7.0]
  def change
    add_column :sam_dot_govs, :full_parent_path_name, :string
  end
end
