class Pipeline < ApplicationRecord
  include Pid

  belongs_to :user
  belongs_to :sam_dot_gov

  before_create :set_group

  enum :state, PIPELINE_STATES
  enum :stages, [ :researching, :in_pipeline, :responding, :pending_award, :awarded ]

  scope :recent_first, ->() { order('created_at DESC') }

  validates_uniqueness_of :sam_dot_gov_id, scope: :user_id, message: "already added to your pipeline."

  private

  def set_group
    self.group_id = self.user.group_memberships.first.id
  end
end
