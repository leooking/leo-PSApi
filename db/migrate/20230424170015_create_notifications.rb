class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.string :name
      t.string :display_text
      t.string :state, default: 'inactive'
      t.boolean :modal, default: true
      t.boolean :top_bar, default: true
      t.string :top_bar_color, default: 'bg-slate-400'

      t.timestamps
    end
  end
end
