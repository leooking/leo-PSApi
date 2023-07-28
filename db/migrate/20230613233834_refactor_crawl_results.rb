class RefactorCrawlResults < ActiveRecord::Migration[7.0]
  def change
    add_column :crawl_results, :page_title, :string
    add_column :crawl_results, :url, :string
    add_column :crawl_results, :raw_text, :string
    remove_column :crawl_results, :total_pages, :integer
    remove_column :crawl_results, :crawl_results, :jsonb
    remove_column :crawl_results, :crawl_identifier, :string
    remove_column :crawl_results, :crawl_name, :string
    remove_column :crawl_results, :target_url, :string
  end
end
