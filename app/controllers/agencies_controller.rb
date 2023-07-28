# frozen_string_literal: true

class AgenciesController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /agencies?q=cheese%20pizza
  def index
    agencies = Agency.all.order(:agency_name)
    agencies = agencies.search(params[:q]) if params[:q].present?
    if agencies
      aarr = [] 
      agencies.each do |a|
        aarr << {agency_name: a.agency_name, agency_code: a.agency_code, sub_department: a.sub_department, acronym: a.acronym, employment: a.employment, website_url: a.website_url, strategic_plan_url: a.strategic_plan_url}
      end
      render json: aarr
    else
      render json: {message: 'No results, search again!'}, status: 404 and return
    end
  end

  # GET /state_agencies?q=cheese%20pizza
  def state_agencies
    state = State.all.order(:name)
    if state
      response = []

      state.each do |s|
        state_agencies = s.state_agencies
        state_agencies_data = []
        state_agencies.each do |a|
          state_agencies_data << {agency_name: a.name, url: a.url, pid: a.pid}
        end

        response << { pid: s.pid, state_name: s.name,
                      abbreviation: s.abbreviation, homepage: s.homepage,
                      procurement: s.procurement, children: state_agencies_data }
      end
      render json: response
    else
      render json: {message: 'No results, search again!'}, status: 404 and return
    end
  end
end
