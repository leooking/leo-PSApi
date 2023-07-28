# frozen_string_literal: true

class SamDotGovCollection < BaseCollection

  def ensure_filters
    ensure_due_date if params[:due_date]
    ensure_searching
  end

  private

  def ensure_due_date
    filter { @relation.active }

    case params[:due_date]
    when 'Next 30 days'
      filter { @relation.due_next_30 }
    when 'Next 60 days'
      filter { @relation.due_next_60 }
    when 'Next 90 days'
      filter { @relation.due_next_90 }
    end
  end

  def ensure_searching
    ensure_keywords if params[:keywords]
    ensure_naics if params[:naics]
    ensure_set_asides if params[:set_asides]
    ensure_types if params[:type]
  end

  def ensure_keywords
    filter { @relation.search_keywords(params[:keywords]) }
  end

  def ensure_naics
    filter { @relation.search_naics(params[:naics]) }
  end

  def ensure_set_asides
    set_asides = params[:set_asides].split(",").map(&:strip)
    if set_asides.include?('full') && set_asides.length > 1
      set_asides.delete('full')
      @relation = @relation.where.not(set_aside_code: set_asides)
    elsif !set_asides.include?('full')
      filtered_results = set_asides.map { |type| @relation.search_set_asides(type) }
      @relation = filtered_results.reduce(:+)
    end
  end

  def ensure_types
    types = params[:type].split(",").map(&:strip)
    filtered_results = types.map { |type| @relation.search_types(type) }
    @relation = filtered_results.reduce(:+)
  end  
end
