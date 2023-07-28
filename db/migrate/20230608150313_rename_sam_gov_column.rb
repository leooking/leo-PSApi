class RenameSamGovColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :sam_dot_govs, :type, :oppty_type
  end
end
