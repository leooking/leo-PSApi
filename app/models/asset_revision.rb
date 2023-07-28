# frozen_string_literal: true

class AssetRevision < ApplicationRecord
  include Pid
  include Loggable

  belongs_to :project, optional: true
  belongs_to :user
  belongs_to :asset_generator
  belongs_to :asset
  has_many :asset_interactions

  # default_scope { order(:created_at) }
  
end
