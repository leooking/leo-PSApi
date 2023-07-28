# frozen_string_literal: true

class Project < ApplicationRecord
  include Pid
  include Notable

  belongs_to :org
  belongs_to :group
  belongs_to :user
  has_many :project_resources
  has_many :resources, through: :project_resources
  has_many :project_teams
  has_many :team, through: :project_teams, source: :user
  has_many :asset_interactions
  has_many :group_projects
  has_many :groups, through: :group_projects
  has_many :project_orgs
  has_many :orgs, through: :project_orgs
  # has_many :project_users
  # has_many :users, through: :project_users # to fix relocate_object project ownership 404
  has_many :folder_projects, dependent: :destroy
  has_many :folders, through: :folder_projects
  
  # The jailbreak dilemma:
  # After jailbreaking the can be shared asset across projects
  has_many :asset_projects
  has_many :assets, through: :asset_projects
  # Formerly, asset belongs to only one project
  has_many :assets
  
  def orphan?
    if self.folders.count == 0
      true 
    else
      false
    end
  end

end
