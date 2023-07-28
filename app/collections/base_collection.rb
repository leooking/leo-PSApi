# frozen_string_literal: true

class BaseCollection
  attr_reader :params

  def initialize(relation, params)
    @relation = relation
    @params = params
  end

  def results
    @results ||= begin
      ensure_filters
    #   ensure_sorting

      @relation
    end
  end

  private

  def filter
    @relation = yield
  end

  def ensure_filters; end
end
