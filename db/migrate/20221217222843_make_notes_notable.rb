class MakeNotesNotable < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :notable_type, :string,  null: false
    add_column :notes, :notable_id,   :integer, null: false
    add_index  :notes, [:notable_id, :notable_type]
  end
end
