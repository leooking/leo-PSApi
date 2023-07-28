# frozen_string_literal: true

module UrlValidator
  extend ActiveSupport::Concern
  included do
    def valid_url?(url)
      uri = URI.parse(url)
      if uri && uri.scheme && PublicSuffix.valid?(uri.host) && %w[http https].include?(uri.scheme)
        result = true
      end
      return result
    end
  end
end