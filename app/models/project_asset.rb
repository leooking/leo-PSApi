# frozen_string_literal: true

class ProjectAsset < ApplicationRecord
  belongs_to :user
  belongs_to :asset
end
