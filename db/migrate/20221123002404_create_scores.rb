class CreateScores < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :evaluator
      t.string :name
      t.string :description
      t.string :attribute
      t.integer :score
      t.integer :maximum
      t.integer :weight
      t.string :pid, null: false

      t.timestamps
    end
  end
end
