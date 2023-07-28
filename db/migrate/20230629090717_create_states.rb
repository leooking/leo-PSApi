class CreateStates < ActiveRecord::Migration[7.0]
  def change
    create_table :states do |t|
      t.string :name
      t.string :information_url
      t.string :homepage
      t.string :procurement
      t.string :abbreviation
      t.string :pid, null:false

      t.timestamps
    end
  end
end
