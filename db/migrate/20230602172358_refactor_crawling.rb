class RefactorCrawling < ActiveRecord::Migration[7.0]
  def up
    add_column :crawl_results, :crawl_results, :jsonb, default: {}
    remove_column :crawl_results, :raw_text
    rename_column :crawl_results, :crawl_instruction_id, :crawl_id
    rename_column :crawl_results, :depth, :total_pages
    remove_column :crawls, :crawl_result
  end
  def down
    add_column :crawls, :crawl_result, :jsonb, default: {}
    rename_column :crawl_results, :total_pages, :depth
    rename_column :crawl_results, :crawl_id, :crawl_instruction_id
    add_column :crawl_results, :raw_text, :text
    remove_column :crawl_results, :crawl_results
  end
end
