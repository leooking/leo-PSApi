class CreateFavoritePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_prompts do |t|
      t.integer :user_id
      t.integer :prompt_id

      t.timestamps
    end
  end
end
