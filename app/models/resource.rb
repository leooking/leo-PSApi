# frozen_string_literal: true

class Resource < ApplicationRecord
  include Pid
  include Notable
  include ResourceSearch
  
  # https://github.com/mbleigh/acts-as-taggable-on
  acts_as_taggable_on :source#, :type
  acts_as_taggable_tenant :org_id # tag collections scoped to org

  belongs_to :user
  has_many :project_resources
  has_many :projects, through: :project_resources
  has_many :group_resources
  has_many :groups, through: :group_resources
  has_many :org_resources
  has_many :orgs, through: :org_resources
  # has_many :resource_users
  # has_many :users, through: :resource_users
  has_many :folder_resources, dependent: :destroy
  has_many :folders, through: :folder_resources
  has_one :crawl, dependent: :destroy
  belongs_to :org, optional: true       # optional so we can have shared (non-associated) resources


  default_scope { order(created_at: :desc) }

  scope :pdf_only, -> { where("data_asset['content_type'] == ?", 'application/pdf') }

  def resource_type
    if !self.source_url.nil?
      return 'URL'
    else
      return 'File'
    end
  end

  def orphan?
    if self.folders.count == 0
      true 
    else
      false
    end
  end

end
