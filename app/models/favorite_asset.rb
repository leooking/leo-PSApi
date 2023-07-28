# frozen_string_literal: true

class FavoriteAsset < ApplicationRecord
  belongs_to :user
  belongs_to :asset
end
