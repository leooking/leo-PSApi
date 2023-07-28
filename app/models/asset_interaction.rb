# frozen_string_literal: true

class AssetInteraction < ApplicationRecord
  include Pid
  include Loggable

  # include PgSearch::Model
  # multisearchable against: [:prompt, :response]
  # pg_search_scope :search_keywords, against: [:title, :description, :sub_tier, :office, :naics_code, :oppty_type, :base_type]

  belongs_to :project, optional: true
  belongs_to :user
  belongs_to :asset_generator
  belongs_to :asset
  belongs_to :asset_revision, optional: true

  default_scope { order(:created_at) }
  
end
