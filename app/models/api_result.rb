# frozen_string_literal: true

class ApiResult < ApplicationRecord
  include Pid
  
  belongs_to :api_request

  default_scope { order(:created_at) }
  
end
