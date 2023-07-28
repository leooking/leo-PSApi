class CreateCrawls < ActiveRecord::Migration[7.0]
  def change
    create_table :crawls do |t|
      t.string :crawl_name
      t.string :target_url
      t.integer :max_pages
      t.integer :max_depth
      t.datetime :last_crawl
      t.string :scheduling_memo
      t.jsonb :crawl_result, default: {}
      t.string :state, default: 'proposed'
      t.string :pid
      
      t.timestamps
    end
  end
end
