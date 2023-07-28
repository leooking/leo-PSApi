class DowncaseSamGovColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :sam_dot_govs, :CGAC, :cgac
  end
end
