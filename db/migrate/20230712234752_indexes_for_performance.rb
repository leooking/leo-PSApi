class IndexesForPerformance < ActiveRecord::Migration[7.0]
  def change
    add_index :sam_dot_govs, :pid
  end
end
