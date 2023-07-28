class AddNotesForRbac < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :notes, :string
    add_column :permissions, :notes, :string
  end
end
