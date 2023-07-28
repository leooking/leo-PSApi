# frozen_string_literal: true

class DashboardController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /dashboard
  # User specfic stuff
  def show
    u = User.find_by(pid: @current_user.pid)
    o = u.org
    projects = Project.where(org_id: @current_user.org.id).all

    
    # this to eliminate private generators from the global array
    pri_gen_ids = OrgAssetGenerator.pluck(:asset_generator_id)
    
    private_g = o.private_generators  # the method is scoped active state
    prarr = []
    if private_g
      private_g.each do |g|
        prarr << {scope: 'private', pid: g.pid, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction}
      end
    end
    
    ord_g = AssetGenerator.ordered.excluding(private_g)
    ordarr = []
    if ord_g
      ord_g.each do |g|
        ordarr << {scope: 'global', pid: g.pid, display_order: g.display_order, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction} unless pri_gen_ids.include? g.id
      end
    end
    
    unord_g = AssetGenerator.unordered.excluding(private_g)
    unordarr = []
    if unord_g
      unord_g.each do |g|
        unordarr << {scope: 'global', pid: g.pid, display_order: g.display_order, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction} unless pri_gen_ids.include? g.id
      end
    end

    parr = []
    if projects
      projects.each do |p|

        rarr = []
        resorcs = p.resources
        resorcs.each do |r|
          rarr << {pid: r.pid, name: r.name}  
        end

        is_team_member = p.team.include? @current_user
        team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
        team_size = p.team.count
        resource_count = p.resources.count
        asset_count = p.assets.count
        start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
        deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
        parr << {pid: p.pid, name: p.name, description: p.description, objective: p.objective, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, deadline: deadline, is_team_member: is_team_member, team_owner: team_owner, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr}
      end
      dm = u.org.dash_message
    end

    render json: {org_pid: @current_user.org.pid, dashboard_message: dm, private_generators: prarr, generators: ordarr + unordarr, projects: parr}
    
    logger.debug 'foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo'
    logger.debug prarr.count
    logger.debug ordarr.count
    logger.debug unordarr.count
    logger.debug 'foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo  foo'
    
  end

end
