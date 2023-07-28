class AddDashMessageToOrgs < ActiveRecord::Migration[7.0]
  def change
    add_column :orgs, :dash_message, :text
  end
end
