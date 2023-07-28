class AddDefaultOrgTypeToOrgs < ActiveRecord::Migration[7.0]
  def change
    change_column_default :orgs, :org_type, from: nil, to: 'smb'
  end
end
