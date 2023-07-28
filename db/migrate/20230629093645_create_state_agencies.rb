class CreateStateAgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :state_agencies do |t|
      t.string :name
      t.string :url
      t.references :state, null: false, foreign_key: true
      t.string :pid, null:false

      t.timestamps
    end
  end
end
