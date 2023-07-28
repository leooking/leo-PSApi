# frozen_string_literal: true

class PromptsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /prompts
  def index
    u = @current_user
    o = u.org
    g = u.group
    
    group = []
    org = []
    org_prompts = Prompt.where(org_id: o.id).all
    org_prompts.each do |p|
      favorited = u.starred_prompts.include? p
      group     << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope} if p.scope == 'group'     && p.group == g
      org       << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope} if p.scope == 'org'       && p.org == o
    end
    
    featured = []
    featured_prompts  = Prompt.where(scope: 'featured').all
    featured_prompts.each do |p|
      favorited = u.starred_prompts.include? p
      featured  << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope} if p.scope == 'featured'
    end

    mine = []
    fav_prompts = u.starred_prompts
    my_prompts = Prompt.where(user_id: u.id)
    fav_prompts.each do |p|
      favorited = u.starred_prompts.include? p
      mine << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope}
    end

    my_prompts.each do |p|
      favorited = u.starred_prompts.include? p
      mine << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope} if p.scope == 'mine'
    end

    payload = {mine: mine.uniq, group: group, org: org, featured: featured}
    render json: payload, status: :ok
  end
  
  # GET /prompts/pid
  def show
    p = Prompt.find_by(pid: params[:id])
    if p
      favorited = @current_user.starred_prompts.include? p
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, favorited: favorited, prompt_text: p.prompt_text, scope: p.scope}
      render json: payload, status: :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /prompts/pid/add_to_favorites
  def add_to_favorites
    p = Prompt.find_by(pid: params[:id])
    if p
      @current_user.starred_prompts << p
      render json: {message: "Added #{p.name} to favorite prompts"}, status: :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /prompts/pid/remove_from_favorites
  def remove_from_favorites
    p = Prompt.find_by(pid: params[:id])
    if p
      @current_user.starred_prompts.delete p
      render json: {message: "Removed #{p.name} from favorite prompts"}, status: :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /prompts
  def create
    u = @current_user
    o = u.org
    g = u.group
    p = Prompt.new(prompt_params)
    p.user_id     = u.id
    p.group_id    = g.id
    p.org_id      = o.id
    if p.save
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, prompt_text: p.prompt_text, scope: p.scope}
      render json: payload, status: :created
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end
  
  # PUT /prompts/pid
  def update
    p = Prompt.find_by(pid: params[:id])
    if p
      p.update(prompt_params)
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, prompt_text: p.prompt_text, scope: p.scope}
      render json: payload, status: :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # DELETE /prompts/pid
  def destroy
    p = Prompt.find_by(pid: params[:id])
    if p
      p.destroy
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

    def prompt_params
      params.require(:prompt).permit(:name, :description, :prompt_text, :scope)
    end

end