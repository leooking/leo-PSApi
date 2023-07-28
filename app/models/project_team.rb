# frozen_string_literal: true

class ProjectTeam < ApplicationRecord
  belongs_to :project
  belongs_to :user
end
