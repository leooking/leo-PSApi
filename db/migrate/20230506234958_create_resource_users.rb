class CreateResourceUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_users do |t|
      t.integer :resource_id
      t.integer :user_id

      t.timestamps
    end
  end
end
