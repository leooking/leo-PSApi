class AddPidToPipeline < ActiveRecord::Migration[7.0]
  def change
    add_column :pipelines, :pid, :string, null: false
  end
end
