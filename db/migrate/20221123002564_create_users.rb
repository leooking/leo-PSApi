
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :email,  null: false, default: ""
      t.boolean :email_verified, default: false
      
      t.datetime  :last_login
      t.integer   :login_count, default: 0  
      
      # in-house auth 
      t.string :password_hash
      t.string :confirmation_token
      t.string :auth_token
      t.string :refresh_token
      t.string :password_reset_token

      t.integer :org_id
      t.integer :group_id

      t.string :pid,    null: false
      
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :pid,   unique: true
  end
end
