class CreateCrawlResults < ActiveRecord::Migration[7.0]
  def change
    create_table :crawl_results do |t|
      t.text :raw_text
      t.string :name
      t.string :target
      t.integer :depth
      t.integer :crawl_instruction_id

      t.timestamps
    end
  end
end
