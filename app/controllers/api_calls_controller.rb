# frozen_string_literal: true

class ApiCallsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # POST /api_calls/new_request
  # {"name": "...", "description": "...", "notes": "...", "request_json": {"foo": "bar"}, "endpoint": "..."}
  def new_request
    name = params[:name]
    description = params[:description]
    notes = params[:notes]
    request_json = params[:request_json]
    endpoint = params[:endpoint]
    req = ApiRequest.new(name: name, description: description, notes: notes, request_json: request_json, endpoint: endpoint)
    if req.save
      payload = {api_request_id: req.id, api_request_pid: req.pid, name: req.name}
      render json: payload
    else
      render json: {error: 'there was an error'}, status: 400
    end
  end
  
  # POST /api_calls/result
  # {"api_request_id": 864, "json_response": {"foo": "bar"}, "http_status": "200"}
  def result
    api_request_id = params[:api_request_id]
    json_response = params[:json_response]
    http_status = params[:http_status]
    req = ApiRequest.find(api_request_id)
    res = ApiResult.new(api_request_id: api_request_id, json_response: json_response, http_status: http_status)
    if res.save && req
      payload = {api_request_id: res.id, api_request_pid: res.pid, http_status: res.http_status}
      render json: payload
    else
      render json: {error: 'there was an error'}, status: 400
    end
  end

end
