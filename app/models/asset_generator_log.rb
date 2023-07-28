# frozen_string_literal: true

class AssetGeneratorLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  belongs_to :user
  belongs_to :asset_generator
end
