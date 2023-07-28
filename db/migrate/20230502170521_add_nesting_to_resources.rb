class AddNestingToResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :parent_id, :integer
    add_column :resources, :lft, :integer
    add_column :resources, :rgt, :integer
    add_index :resources, :parent_id
    add_index :resources, :lft
    add_index :resources, :rgt
  end
end
