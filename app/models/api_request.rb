# frozen_string_literal: true

class ApiRequest < ApplicationRecord
  include Pid

  has_many :api_results

  default_scope { order(:name) }

end
