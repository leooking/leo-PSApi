# frozen_string_literal: true

class Allocation < ApplicationRecord
  belongs_to :org
  belongs_to :license
  belongs_to :user
end
