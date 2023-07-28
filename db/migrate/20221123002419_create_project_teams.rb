class CreateProjectTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :project_teams do |t|
      t.integer :project_id
      t.integer :user_id

      t.timestamps
    end
  end
end
