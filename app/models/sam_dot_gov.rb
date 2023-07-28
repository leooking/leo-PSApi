# frozen_string_literal: true

class SamDotGov < ApplicationRecord
  include Pid
  include PgSearch::Model

  pg_search_scope :search_keywords, against: [:notice_id, :sol_number, :title, :description, :sub_tier, :office, :naics_code, :oppty_type, :base_type],
    using: { tsearch: { dictionary: 'english', prefix: true }}, ignoring: [:accents]
  pg_search_scope :search_naics, against: [:naics_code],
    using: { tsearch: { dictionary: 'english', prefix: true, any_word: true }}, ignoring: [:accents]
  pg_search_scope :search_set_asides, against: [:set_aside_code],
    using: { tsearch: { dictionary: 'english', prefix: true, any_word: true }}, ignoring: [:accents]
  pg_search_scope :search_types, against: [:oppty_type],
    using: { tsearch: { dictionary: 'english', prefix: true, any_word: true }}, ignoring: [:accents]

  scope :active,        -> { where('response_deadline > ?', Date.today) }
  scope :due_next_30,   -> { where(response_deadline: Date.today..Date.today+30.days) }
  scope :due_next_60,   -> { where(response_deadline: Date.today..Date.today+60.days) }
  scope :due_next_90,   -> { where(response_deadline: Date.today..Date.today+90.days) }

  default_scope { order(response_deadline: :desc) }

  has_many :pipelines
  has_many :users, through: :pipelines

end

# Searching and returning:
#   title
#   link
#   description
#   sol_number
#   sub_tier
#   office
#   posted_date
#   oppty_type
#   set_aside_code
#   response_deadline
#   naics_code

# keyword search sql:
# "SELECT \"sam_dot_govs\".* FROM \"sam_dot_govs\" INNER JOIN (SELECT \"sam_dot_govs\".\"id\" AS pg_search_id, (ts_rank((to_tsvector('simple', coalesce(\"sam_dot_govs\".\"title\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"description\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"sub_tier\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"office\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"naics_code\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"oppty_type\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"base_type\"::text, ''))), (to_tsquery('simple', ''' ' || 'William' || ' ''') && to_tsquery('simple', ''' ' || 'Mundorf' || ' ''')), 0)) AS rank FROM \"sam_dot_govs\" WHERE ((to_tsvector('simple', coalesce(\"sam_dot_govs\".\"title\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"description\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"sub_tier\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"office\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"naics_code\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"oppty_type\"::text, '')) || to_tsvector('simple', coalesce(\"sam_dot_govs\".\"base_type\"::text, ''))) @@ (to_tsquery('simple', ''' ' || 'William' || ' ''') && to_tsquery('simple', ''' ' || 'Mundorf' || ' ''')))) AS pg_search_cd02962423c171da4fa2f4 ON \"sam_dot_govs\".\"id\" = pg_search_cd02962423c171da4fa2f4.pg_search_id ORDER BY pg_search_cd02962423c171da4fa2f4.rank DESC, \"sam_dot_govs\".\"id\" ASC"

