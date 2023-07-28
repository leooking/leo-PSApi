class IndexesForSam < ActiveRecord::Migration[7.0]
  def change
    add_index :sam_dot_govs, :set_aside_code
    add_index :sam_dot_govs, :oppty_type
  end
end
