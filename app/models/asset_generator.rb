# frozen_string_literal: true

class AssetGenerator < ApplicationRecord
  include Pid
  has_many :assets
  has_many :asset_interactions
  has_many :asset_generator_logs
  has_many :org_asset_generators
  has_many :orgs, through: :org_asset_generators

  # default_scope { order(:name) }

  scope :ordered, -> { where(state: 'active').where.not(display_order: nil).order(:display_order) }
  scope :unordered, -> { where(state: 'active', display_order: nil).order(:name) }

end
