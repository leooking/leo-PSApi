# frozen_string_literal: true

class CrawlResult < ApplicationRecord
  belongs_to :crawl

  default_scope { order(:created_at) }
  
end
