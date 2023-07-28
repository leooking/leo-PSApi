class AddUuidToCrawlResults < ActiveRecord::Migration[7.0]
  def change
    add_column :crawl_results, :crawl_result_uuid, :string
  end
end
