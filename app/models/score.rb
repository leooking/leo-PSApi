# frozen_string_literal: true

class Score < ApplicationRecord
  include Pid
  has_many :resources, as: :resourceable
  has_many :notes, as: :notable
end
