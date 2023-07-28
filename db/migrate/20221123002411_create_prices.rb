class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :component
      t.string :name
      t.string :description
      t.integer :dollars
      t.string :pid, null: false

      t.timestamps
    end
  end
end
