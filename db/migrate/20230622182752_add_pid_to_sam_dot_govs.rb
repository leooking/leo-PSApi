class AddPidToSamDotGovs < ActiveRecord::Migration[7.0]
  def change
    add_column :sam_dot_govs, :pid, :string
  end
end
