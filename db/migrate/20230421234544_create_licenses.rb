class CreateLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :licenses do |t|
      t.string    :name
      t.string    :note
      t.integer   :quantity
      t.string    :stripe_invoice_id
      t.datetime  :issued_on
      t.datetime  :expires_on
      t.integer   :org_id, null: false
      t.string    :pid, null: false

      t.timestamps
    end
  end
end
