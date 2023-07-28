class CreateAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :assets do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.string :name
      t.string :description
      t.string :input
      t.string :source
      t.string :link
      t.text   :text
      t.string :asset_type
      t.string :state
      t.string :pid, null: false

      t.timestamps
    end
  end
end
