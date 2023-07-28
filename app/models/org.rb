# frozen_string_literal: true

class Org < ApplicationRecord
  include Pid
  has_many :licenses,     dependent: :destroy
  has_many :groups,       dependent: :destroy
  has_many :allocations,  dependent: :destroy
  has_many :users,        dependent: :destroy
  has_many :prompts
  has_many :hook_logs
  has_many :org_asset_generators
  has_many :asset_generators, through: :org_asset_generators
  has_many :asset_orgs
  has_many :assets, through: :asset_orgs
  has_many :org_resources
  has_many :resources, through: :org_resources
  has_many :project_orgs
  has_many :projects, through: :project_orgs
  has_many :resources,    dependent: :destroy
  

  after_commit(on: :create) do
    GcsService.new(org: self).create_bucket
    GcsService.new(org: self).create_qdrant_collection
  end

  def total_licenses
    licenses.sum(:quantity)
  end

  def available_licenses
    count = 0
    licenses&.each do |license|
      count += license.allocations_available
    end
    count
  end

  def licenses_summary
    allocated = 0
    available = 0
    expiry = nil
    licenses&.each do |license|
      allocated = license.allocated_quantity
      available = license.allocations_available
      expiry = license.expires_on.strftime('%m/%d/%Y') if expiry.nil? || expiry < license.expires_on.strftime('%m/%d/%Y')
    end
    { allocated_licenses: allocated, available_licenses: available, licenses_expiry: expiry }
  end

  def private_generators
    self.asset_generators.where(state: 'active')
  end

  def org_assets
    user_ids = self.users.pluck(:id)
    Asset.where(user_id: user_ids)
  end
  
end
