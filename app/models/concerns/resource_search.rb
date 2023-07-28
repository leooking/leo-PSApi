module ResourceSearch
  extend ActiveSupport::Concern
  included do

    include PgSearch::Model

    pg_search_scope :search_full_text_scope,
      against:  { raw_text: 'A', name: 'B' },
      using:    { tsearch: { dictionary: 'english', prefix: true }},
      ignoring: [:accents]

    def self.search_full_text(query)
      if query.present?
        search_full_text_scope(query)
      end
    end

  end
end
