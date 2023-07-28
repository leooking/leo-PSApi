class CreateOrgResources < ActiveRecord::Migration[7.0]
  def change
    create_table :org_resources do |t|
      t.integer :org_id
      t.integer :resource_id

      t.timestamps
    end
  end
end
