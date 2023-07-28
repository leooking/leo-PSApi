# frozen_string_literal: true

class CrawlController < ApplicationController
  include Authentication

  before_action :require_api_key

  # POST /crawl/result
  # {"crawl_name": "FAA Mission", "target_url": "https://example.com", "total_pages": 1, "crawl_id": 1, "crawl_results": "json"}
  def result
    r = CrawlResult.create(crawl_params)
    if r
      payload = {crawl_name: r.crawl_name, target_url: r.target_url, total_pages: r.total_pages}
      render json: payload, status: :ok
    else
      render json: {error: 'An error occurred'}, status: 400
    end
  end

  private

    def crawl_params
      params.delete(:crawl)
      params.permit(:crawl_name, :target_url, :total_pages, :crawl_id, :crawl_results)
    end

end