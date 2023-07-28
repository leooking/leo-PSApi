# frozen_string_literal: true

class StaffController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # POST /staff/prov151on
  def prov151on
    # 'file' is the key for the uploaded file
    tempfile = params[:file]
    unless tempfile
      render json: {error: 'Not found.'}, status: 404 and return
    end
    CsvService.new(tempfile: tempfile).provision_users   
  end

  private
  
    def staff_params
      params.permit!
    end

end