class CreateProjectOrgs < ActiveRecord::Migration[7.0]
  def change
    create_table :project_orgs do |t|
      t.integer :project_id
      t.integer :org_id

      t.timestamps
    end
  end
end
