class ProhibitNullPidOnInteractions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :asset_interactions, :pid, false
  end
end
