class CreateAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :agencies do |t|
      t.string :agency_name
      t.string :agency_code
      t.string :sub_department
      t.string :acronym
      t.integer :employment
      t.string :website_url
      t.string :strategic_plan_url
      t.string :strategic_plan_url_additional
      t.string :pid, null:false

      t.timestamps
    end
  end
end
