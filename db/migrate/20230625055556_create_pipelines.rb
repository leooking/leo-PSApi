class CreatePipelines < ActiveRecord::Migration[7.0]
  def change
    create_table :pipelines do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sam_dot_gov, null: false, foreign_key: true

      t.timestamps
    end
  end
end
