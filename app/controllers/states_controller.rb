# frozen_string_literal: true

class StatesController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /states?q=cheese%20pizza
  def index
    states = State.all.order(:name)
    states = states.search(params[:q]) if params[:q].present?
    if states
      response = []

      states.each do |s|
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
