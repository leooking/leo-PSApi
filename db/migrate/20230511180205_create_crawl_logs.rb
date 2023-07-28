class CreateCrawlLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :crawl_logs do |t|
      t.datetime :crawled_at
      t.integer :crawl_id
      t.integer :crawled_pages

      t.timestamps
    end
  end
end
