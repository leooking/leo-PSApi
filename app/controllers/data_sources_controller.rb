class DataSourcesController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /data_sources/naics_codes
  def naics_codes
    naics = NaicsCode.all.order(:naics_2022_code)

    narr = naics.map do |n|
      { code: n.naics_2022_code, title: n.naics_2022_title }
    end

    render json: narr
  end

  # GET /data_sources/opportunities?type=Solicitation%20Award%20Notice
  def opportunities
    # keywords          = params[:keywords]   # [:title, :description, :sub_tier, :office, :naics_code, :oppty_type, :base_type]
    # naics             = params[:naics]      # naics_code
    # set_aside_code    = params[:set_asides] # set_aside_code
    # types             = params[:type]       # oppty_type
    # due_date          = params[:due_date]   # response_deadline

    limit = 100

    # if due_date == 'Next 30 days'
    #   opps = SamDotGov.active.due_next_30
    # elsif due_date == 'Next 60 days'
    #   opps = SamDotGov.active.due_next_60
    # elsif due_date == 'Next 90 days'
    #   opps = SamDotGov.active.due_next_90
    # else # for the no params case
    #   opps = SamDotGov.active
    # end
    # opps = opps.search_keywords(keywords)       if keywords
    # opps = opps.search_naics(naics)             if naics
    # opps = opps.search_set_asides(set_aside_code) if set_aside_code
    # opps = opps.search_types(types)             if types
    opps_relation = SamDotGovCollection.new(SamDotGov.all, filter_params).results
    opps = SamDotGov.all.where(id: opps_relation.map { |o| o[:id] })
    opps = opps.page(params[:page] || 1).per(params[:per] || 100)


    # raise opps.to_sql
    oarr = opps.limit(limit).map do |o|
      posted_date = o.posted_date ? o.posted_date.strftime('%m/%d/%Y') : nil
      due_date = o.response_deadline ? o.response_deadline.strftime('%m/%d/%Y') : nil

      {
        id: o.id, name: o.title, link: o.link, sol_number: o.sol_number,
        sub_tier: o.sub_tier, office: o.office, posted_date: posted_date, notice_type: o.oppty_type, pid: o.pid,
        set_aside_code: o.set_aside_code, due_date: params[:due_date], naics_code: o.naics_code, description: o.description
      }
    end

    render json: { records_found: opps.count, qty_returned: oarr.length, search_result: oarr }
  end

  private

  def filter_params
    params.permit(:keywords, :naics, :set_asides, :type, :due_date, :include_expired)
  end
end
