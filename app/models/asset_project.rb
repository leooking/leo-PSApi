# frozen_string_literal: true

class AssetProject < ApplicationRecord
  belongs_to :asset
  belongs_to :project
end
