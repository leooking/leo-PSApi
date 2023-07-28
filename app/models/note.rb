# frozen_string_literal: true

class Note < ApplicationRecord
  include Pid
  belongs_to :notable, polymorphic: true
  belongs_to :user

  default_scope { order(created_at: :desc) }
  
end
