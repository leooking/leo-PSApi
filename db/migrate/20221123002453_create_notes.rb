class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.integer :user_id
      t.string :text
      t.string :pid, null: false

      t.timestamps
    end
  end
end
