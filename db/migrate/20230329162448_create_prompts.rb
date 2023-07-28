class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string  :name
      t.string  :description
      t.text    :prompt_text
      t.string  :scope, default: 'me'
      t.integer :user_id, null: false
      t.integer :group_id
      t.integer :org_id
      t.string  :pid, null: false

      t.timestamps
    end
  end
end
