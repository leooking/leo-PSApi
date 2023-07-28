# frozen_string_literal: true

module Notable
  extend ActiveSupport::Concern
  included do
    has_many :notes, as: :notable, dependent: :destroy
  end
end
