# frozen_string_literal: true

class PipelinesController < ApplicationController
  include Authentication
  include ExceptionHandler

  before_action :require_api_key
  before_action :require_sign_in
  before_action :required_params, only: :create
  before_action :set_group, only: :index
  before_action :set_pipeline, only: [:update, :pipeline_stage]
  before_action :filter_params, only: :index

  # GET /pipelines
  def index
    if filter_params[:stage].present?
      filter_stages = filter_params[:stage].split(',')
      stage_values = filter_stages.map { |stage| PIPELINE_STAGES.index(stage) }
      pipelines = @current_user.pipelines.where(state: 'active', stages: stage_values)
    else
      pipelines = @current_user.pipelines.where(state: 'active')
    end
    pipelines = SamDotGovCollection.new(pipelines, filter_params).results
    pipelines = pipelines.page(params[:page] || 1).per(params[:per] || 100)

    oarr = pipelines.map do |pipeline|
      o = pipeline.sam_dot_gov
      posted_date = o.posted_date ? o.posted_date.strftime('%m/%d/%Y') : nil
      due_date = o.response_deadline ? o.response_deadline.strftime('%m/%d/%Y') : nil

      {
        name: o.title, link: o.link, sol_number: o.sol_number, sub_tier: o.sub_tier,
        office: o.office, posted_date: posted_date, notice_type: o.oppty_type,
        set_aside_code: o.set_aside_code, due_date: due_date, naics_code: o.naics_code,
        description: o.description, pipeline_pid: pipeline.pid, pipeline_state: pipeline.state,
        pipeline_stage: PIPELINE_STAGES.at(Pipeline.stages[pipeline.stages])
      }
    end

    pagination = {count: pipelines.count, total_count: pipelines.total_count, current_page: pipelines.current_page, pages: pipelines.total_pages, per_page: pipelines.limit_value}

    render json: {data: oarr, pagination_info: pagination }
  end

  # POST /pipelines
  def create
    pipeline = @current_user.pipelines.new(sam_dot_gov_id: sam_dot_gov.id)

    if pipeline.save
      render json: {message: "Added to your pipeline successfully"}, status: 200
    else
      render json: {error: pipeline.errors.full_messages.to_sentence}, status: 400
    end
  end

  def update
    if @pipeline.archived!
      render json: {message: "Pipeline successfully archived"}, status: 200
    else
      render json: {error: @pipeline.errors.full_messages.to_sentence}, status: 400
    end
  end

  def pipeline_stage
    if @pipeline.update(stages: PIPELINE_STAGES.index(params[:stage]))
      render json: {message: "Pipeline successfully #{params[:stage]}"}, status: 200
    else
      render json: {error: @pipeline.errors.full_messages.to_sentence}, status: 400
    end
  end

  # DELETE /pipelines/:id
  def destroy
    pipeline = @current_user.pipelines.find_by(sam_dot_gov: sam_dot_gov.id)

    if pipeline
      pipeline.destroy
      render json: {message: "Successfully removed from your pipeline."}, status: 200
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

  def required_params
    params.require(:sam_dot_gov_pid)
  end

  def set_group
    @group = @current_user.group_memberships.last
  end

  def sam_dot_gov
    SamDotGov.find_by(pid: params[:sam_dot_gov_pid])
  end

  def filter_params
    params.permit(:stage, :keywords)
  end

  def set_pipeline
    @pipeline = Pipeline.find_by(pid: params[:id])
  end
end
