class State < ApplicationRecord
  include Pid
  include PgSearch::Model

  has_many :state_agencies, dependent: :destroy

  pg_search_scope :search, against: [:name, :abbreviation],
  using:    { tsearch: { dictionary: 'english', prefix: true }},
  ignoring: [:accents]
end
