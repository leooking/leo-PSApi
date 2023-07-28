# frozen_string_literal: true

class Agency < ApplicationRecord
  include Pid
  include PgSearch::Model

  pg_search_scope :search, against: [:agency_name, :agency_code, :sub_department, :acronym],
    using:    { tsearch: { dictionary: 'english', prefix: true }},
    ignoring: [:accents]

end
