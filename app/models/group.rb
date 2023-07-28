# frozen_string_literal: true

class Group < ApplicationRecord
  include Pid
  belongs_to :org
  belongs_to :creator, class_name: :User, foreign_key: :user_id, optional: true
  has_many :group_users
  has_many :members, through: :group_users, source: :user
  has_many :prompts
  has_many :projects, dependent: :destroy
  has_many :asset_groups
  has_many :assets, through: :asset_groups
  has_many :group_resources
  has_many :resources, through: :group_resources
  has_many :group_projects
  has_many :projects, through: :group_projects
  has_many :folder_groups
  has_many :folders, through: :folder_groups

  # calling group.members returns active and inactive
  # so this creature returns only active
  def active_members
    auarr = []
    gu = GroupUser.where(group_id: self.id, active: true)
    gu.each do |gu|
      auarr << gu.user
    end
    auarr
  end

end
