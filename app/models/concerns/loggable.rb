# frozen_string_literal: true

module Loggable
  extend ActiveSupport::Concern
  included do
    has_one :log, as: :loggable, class_name: :AssetGeneratorLog, dependent: :destroy
  end
end
