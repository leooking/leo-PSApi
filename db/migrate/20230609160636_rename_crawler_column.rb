class RenameCrawlerColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :crawl_results, :crawl_result_uuid, :crawl_identifier
  end
end
