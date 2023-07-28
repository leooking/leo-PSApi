class StandardizeCrawlNaming < ActiveRecord::Migration[7.0]
  def change
    rename_column :crawl_results, :name, :crawl_name
    rename_column :crawl_results, :target, :target_url
  end
end
