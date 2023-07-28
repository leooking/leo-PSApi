class AddStateToPipelines < ActiveRecord::Migration[7.0]
  def change
    add_column :pipelines, :state, :integer, default: 0
    add_column :pipelines, :stages, :integer, default: 0
    add_reference :pipelines, :group, foreign_key: true
  end
end
