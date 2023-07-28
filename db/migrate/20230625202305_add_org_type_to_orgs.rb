class AddOrgTypeToOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :orgs, :org_type, :string
  end
end
