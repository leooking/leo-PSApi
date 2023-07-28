class CreateCrawlInstructions < ActiveRecord::Migration[7.0]
  def change
    create_table :crawl_instructions do |t|
      t.string :name
      t.string :notes
      t.string :target
      t.integer :depth, default: 1
      t.integer :days_between_crawls
      t.jsonb   :collector, default: {}
      t.jsonb   :selectors, default: {}
      t.string :state, default: 'suggested'

      t.timestamps
    end
  end
end
