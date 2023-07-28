# frozen_string_literal: true

class AssetAutosave < ApplicationRecord
  belongs_to :asset
  belongs_to :user

  default_scope { order(:created_at) }
  
end
