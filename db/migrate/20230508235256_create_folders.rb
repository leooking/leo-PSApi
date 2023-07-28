class CreateFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :folders do |t|
      t.string  :name
      t.integer :parent_id
      t.integer :user_id
      t.integer :org_id
      t.string :folder_type
      t.string :scope, default: 'org'
      t.string :pid, null: false

      t.timestamps
    end
  end
end
