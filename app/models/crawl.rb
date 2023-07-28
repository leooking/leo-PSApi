# frozen_string_literal: true

class Crawl < ApplicationRecord
  include Pid

  has_many :crawl_results, dependent: :destroy
  belongs_to :resource, optional: true
  
end
