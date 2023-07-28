# frozen_string_literal: true

class Asset < ApplicationRecord
  # include Loggable # used only on interactions
  include Pid
  
  include PgSearch::Model
  # multisearchable against: [:name, :description, :objective]

  pg_search_scope :full_asset_search, 
    against: [:name, :description, :objective],
    associated_against: {asset_interactions: [:prompt, :response, :resource_data, :citation_data, :third_party_data]},
    using:    { tsearch: { dictionary: 'english', prefix: true }},
    ignoring: [:accents]

  # belongs_to :project, optional: true
  has_many :asset_projects
  has_many :projects, through: :asset_projects
  belongs_to :user
  belongs_to :asset_generator
  has_many :asset_revisions, dependent: :destroy
  has_many :asset_interactions, dependent: :destroy
  # has_many :favorite_assets, dependent: :destroy
  # has_many :user_stars, through: :favorite_assets, source: :asset
  has_many :asset_autosave, dependent: :destroy
  has_many :asset_orgs
  has_many :orgs, through: :asset_orgs
  has_many :asset_groups
  has_many :groups, through: :asset_groups
  # has_many :asset_users
  # has_many :users, through: :asset_users
  has_many :asset_folders, dependent: :destroy
  has_many :folders, through: :asset_folders


  # array with newest on front
  def interaction_costs
    self.asset_interactions.order(:created_at).pluck(:token_cost)
  end

  def last_autosave
    self.asset_autosave.last
  end

  def orphan?
    if self.folders.count == 0
      true 
    else
      false
    end
  end

end
