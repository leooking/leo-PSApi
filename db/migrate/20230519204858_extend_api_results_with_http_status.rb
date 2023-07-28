class ExtendApiResultsWithHttpStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :api_results, :http_status, :string
    rename_column :api_results, :api_call_id, :api_request_id
  end
end
