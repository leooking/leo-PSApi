# frozen_string_literal: true

class Folder < ApplicationRecord
  include Pid

  belongs_to :parent, class_name: :Folder, optional: true
  belongs_to :user
  has_many :asset_folders
  has_many :assets, through: :asset_folders#, strict_loading: true
  has_many :folder_resources
  has_many :resources, through: :folder_resources#, strict_loading: true
  has_many :folder_projects
  has_many :projects, through: :folder_projects#, strict_loading: true # needed joins, not includes
  has_many :folder_groups
  has_many :groups, through: :folder_groups

  default_scope { order(:name) }

  def children
    Folder.where(parent_id: self.id)
  end

  def empty?
    case self.folder_type
    when 'asset'
      result = self.assets ? true : false
    when 'project'
      result = self.projects ? true : false
    when 'resource'
      result = self.resources ? true : false
    else
      result = nil
    end
    result
  end

end
