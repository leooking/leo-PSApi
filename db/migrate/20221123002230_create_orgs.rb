class CreateOrgs < ActiveRecord::Migration[7.0]
  def change
    create_table :orgs do |t|
      t.string :name
      t.string :url
      t.string :email_domain
      t.string :pid, null: false

      t.timestamps
    end
  end
end
