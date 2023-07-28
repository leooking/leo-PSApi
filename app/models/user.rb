# frozen_string_literal: true

class User < ApplicationRecord
  include Pid
  has_one :allocation
  has_one :license, through: :allocation
  # I don't remember why I added optional true here but I removed to allow user provisioning on admin
  belongs_to :org # , optional: true
  # deprecated in favor of group memberships with only one active group at a time
  #   belongs_to :group # , optional: true
  has_many :projects
  has_many :prompts
  has_many :project_teams
  has_many :teams, through: :project_teams, source: :project
  has_many :group_users
  has_many :group_memberships, through: :group_users, source: :group
  has_many :role_users
  has_many :roles, through: :role_users
  has_many :notes
  # has_many :assets
  has_many :asset_interactions
  has_many :asset_generator_logs
  has_many :favorite_prompts
  has_many :starred_prompts, through: :favorite_prompts, source: :prompt
  has_many :favorite_assets
  # has_many :starred_assets, through: :favorite_assets, source: :asset
  # has_many :asset_autosave
  has_many :asset_users
  has_many :assets, through: :asset_users
  # has_many :resource_users
  # has_many :resources, through: :resource_users
  has_many :resources
  has_many :folders
  has_many :user_notifications
  has_many :pipelines
  has_many :pipeline_opportunities, through: :pipelines, source: :sam_dot_gov


  def name
    "#{fname} #{lname}"
  end

  after_commit(on: :create) do
    UserMailer.with(user: self).invite_user.deliver_now
  end

  # deactivate all then activate one as create or update
  def activate_in_group(group)
    g = group
    if g && self.org == g.org
      GroupUser.where(user_id: self.id).update_all(active: false)
      gu = GroupUser.where(user_id: self.id, group_id: g.id).first
      if gu
        gu.update(active: true)
      else
        GroupUser.create(user_id: self.id, group_id: g.id, active: true)
      end
      true
    else
      false
    end
  end

  def group
    active = GroupUser.where(user_id: self.id, active: true).first
    if active
      g = active.group
    else
      g = Group.find(self.group_id) # transitioned from user.group_id to GroupUser with active attr
    end
    g
  end

  def name
    "#{fname} #{lname}"
  end

  def permissions
    rarr = []
    roles.each do |r|
      r.permissions.each do |p|
        rarr << p.name
      end
    end
    rarr.uniq
  end

  def asset_24h_total
    assets.where(updated_at: (Time.now - 24.hours)..Time.now).count
  end

  def interaction_24h_total
    assets.where(updated_at: (Time.now - 24.hours)..Time.now).map { |a| a.asset_interactions.length }.sum
  end

  def token_24h_total
    assets.where(updated_at: (Time.now - 24.hours)..Time.now).map(&:total_tokens).sum
  end

  def asset_lifetime_total
    assets.count
  end

  def interaction_lifetime_total
    assets.map { |a| a.asset_interactions.length }.compact.sum
  end

  def token_lifetime_total
    assets.map(&:total_tokens).compact.sum
  end

  def license_expires
    license.expires_on
  end

  def mfa_enabled?
    mfa_enabled
  end

  def generate_otp_secret
    otp_secret = ROTP::Base32.random
    update(otp_secret: otp_secret)
  end

  def get_totp
    OTP::TOTP.new(otp_secret)
  end

  def verify_otp(otp)
    totp = OTP::TOTP.new(otp_secret)
    totp.verify(otp.to_s, last: 4, post: 1)
  end

  def enable_otp
    self.mfa_enabled = true
    generate_otp_secret
  end

  def disable_otp
    self.mfa_enabled = false
    self.otp_secret = nil
  end
end
