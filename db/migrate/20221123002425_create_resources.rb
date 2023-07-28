class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.integer :org_id  # if null, shared resource
      t.integer :user_id
      t.integer :project_id
      t.string :type
      t.string :state
      t.string :name
      t.string :description
      t.string :objective   # what do we want this resource to do for us
      t.string :source      # where did we get this
      t.string :link
      t.string :pid, null: false

      t.timestamps
    end
  end
end
