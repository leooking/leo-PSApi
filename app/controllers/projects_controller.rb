# frozen_string_literal: true

class ProjectsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /projects
  def index2
    projects = Project.where(org_id: @current_user.org.id).all
    if projects
      # root_shared_folders = []
      # root_private_folders = []
      # shared_folders = []
      # private_folders = []

      # orphans block
      shared_orphan_projects = []
      private_orphan_projects = []
      projects.each do |p|
        rarr = []
        resorcs = p.resources
        resorcs.each do |r|
          rarr << {pid: r.pid, name: r.name}  
        end

        team_size = p.team.count
        resource_count = p.resources.count
        asset_count = p.assets.count
        start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
        updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
        deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
        is_team_member = p.team.include? @current_user
        team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
        folder = p.folders.first
        shared_orphan_projects << {user_pid: p.user.pid, pid: p.pid, name: p.name, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at: updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.orphan? && p.scope == 'group'
      end

      projects.where(scope: 'mine', user_id: @current_user.id).each do |p|
        rarr = []
        resorcs = p.resources
        resorcs.each do |r|
          rarr << {pid: r.pid, name: r.name}  
        end

        team_size = p.team.count
        resource_count = p.resources.count
        asset_count = p.assets.count
        start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
        updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
        deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
        is_team_member = p.team.include? @current_user
        team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
        folder = p.folders.first
        private_orphan_projects << {user_pid: p.user.pid, pid: p.pid, name: p.name, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at: updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.orphan? && p.scope == 'mine'
      end
      
      # root_shared_folders block
      rsf = []
      root_shared_folders = Folder.joins(:projects).where(org_id: @current_user.org.id, scope: 'group', parent_id: nil, folder_type: 'project')
      root_shared_folders.each do |f|
        first = f.children
        f_arr = []
        first.each do |f|
          second = f.children
          s_arr = []
          second.each do |f|
            third = f.children
            t_arr = []
            third.each do |f|
              tr_arr = []
              f.projects.each do |p|
                rarr = []
                resorcs = p.resources
                resorcs.each do |r|
                  rarr << {pid: r.pid, name: r.name}  
                end
        
                team_size = p.team.count
                resource_count = p.resources.count
                asset_count = p.assets.count
                start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
                updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
                deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
                is_team_member = p.team.include? @current_user
                team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
                parent_pid = f && f.parent ? f.parent.pid : nil
                folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
                tr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.scope == 'group'
              end
              t_arr << {pid: f.pid, name: f.name, projects: tr_arr}
            end
            sr_arr = []
            f.projects.each do |p|
              rarr = []
              resorcs = p.resources
              resorcs.each do |r|
                rarr << {pid: r.pid, name: r.name}  
              end
      
              team_size = p.team.count
              resource_count = p.resources.count
              asset_count = p.assets.count
              start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
              updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
              deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
              is_team_member = p.team.include? @current_user
              team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
              sr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at: updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.scope == 'group'
            end
            s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, projects: sr_arr}
          end
          fr_arr = []
          f.projects.each do |p|
            rarr = []
            resorcs = p.resources
            resorcs.each do |r|
              rarr << {pid: r.pid, name: r.name}  
            end
    
            team_size = p.team.count
            resource_count = p.resources.count
            asset_count = p.assets.count
            start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
            updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
            deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
            is_team_member = p.team.include? @current_user
            team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
            fr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.scope == 'group'
          end
          f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, projects: fr_arr}
        end
        rr_arr = []
        f.projects.each do |p|
          rarr = []
          resorcs = p.resources
          resorcs.each do |r|
            rarr << {pid: r.pid, name: r.name}  
          end
  
          team_size = p.team.count
          resource_count = p.resources.count
          asset_count = p.assets.count
          start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
          updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
          deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
          is_team_member = p.team.include? @current_user
          team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
          rr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at: updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if p.scope == 'group'
        end
        rsf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, projects: rr_arr}
      end
      
      # root_private_folders block
      rpf = []
      root_private_folders = Folder.joins(:projects).where(org_id: @current_user.org.id, scope: 'mine', parent_id: nil, folder_type: 'project')
      root_private_folders.each do |f|
        first = f.children
        f_arr = []
        first.each do |f|
          second = f.children
          s_arr = []
          second.each do |f|
            third = f.children
            t_arr = []
            third.each do |f|
              tr_arr = []
              f.projects.where(scope: 'mine', user_id: @current_user.id).each do |p|
                rarr = []
                resorcs = p.resources
                resorcs.each do |r|
                  rarr << {pid: r.pid, name: r.name}  
                end
        
                team_size = p.team.count
                resource_count = p.resources.count
                asset_count = p.assets.count
                start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
                updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
                deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
                is_team_member = p.team.include? @current_user
                team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
                parent_pid = f && f.parent ? f.parent.pid : nil
                folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
                tr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if (p.scope == 'mine') && (p.user == @current_user)
              end
              t_arr << {pid: f.pid, name: f.name, projects: tr_arr}
            end
            sr_arr = []
            f.projects.where(scope: 'mine', user_id: @current_user.id).each do |p|
              rarr = []
              resorcs = p.resources
              resorcs.each do |r|
                rarr << {pid: r.pid, name: r.name}  
              end
      
              team_size = p.team.count
              resource_count = p.resources.count
              asset_count = p.assets.count
              start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
              updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
              deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
              is_team_member = p.team.include? @current_user
              team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
              sr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if (p.scope == 'mine') && (p.user == @current_user)
            end
            s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, projects: sr_arr}
          end
          fr_arr = []
          f.projects.where(scope: 'mine', user_id: @current_user.id).each do |p|
            rarr = []
            resorcs = p.resources
            resorcs.each do |r|
              rarr << {pid: r.pid, name: r.name}  
            end
    
            team_size = p.team.count
            resource_count = p.resources.count
            asset_count = p.assets.count
            start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
            updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
            deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
            is_team_member = p.team.include? @current_user
            team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
            fr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at: updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if (p.scope == 'mine') && (p.user == @current_user)
          end
          f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, projects: fr_arr}
        end
        rr_arr = []
        f.projects.where(scope: 'mine', user_id: @current_user.id).each do |p|
          rarr = []
          resorcs = p.resources
          resorcs.each do |r|
            rarr << {pid: r.pid, name: r.name}  
          end
  
          team_size = p.team.count
          resource_count = p.resources.count
          asset_count = p.assets.count
          start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
          updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
          deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
          is_team_member = p.team.include? @current_user
          team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
          rr_arr << {user_pid: p.user.pid, pid: p.pid, name: p.name, folder: folder, scope: p.scope, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr} if (p.scope == 'mine') && (p.user == @current_user)
        end
        rpf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, projects: rr_arr}
      end

      render json: {org_pid: @current_user.org.pid, shared_orphan_projects: shared_orphan_projects, private_orphan_projects: private_orphan_projects, shared_folders: rsf, private_folders: rpf}
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end
  
  # GET /projects
  def index0
    projects = Project.where(org_id: @current_user.org.id).all
    if projects
      parr = []
      projects.each do |p|

        rarr = []
        resorcs = p.resources
        resorcs.each do |r|
          rarr << {pid: r.pid, name: r.name}  
        end

        team_size = p.team.count
        resource_count = p.resources.count
        asset_count = p.assets.count
        start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
        updated_at = p.updated_at ? p.updated_at.strftime('%m/%d/%Y') : nil
        deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
        is_team_member = p.team.include? @current_user
        team_owner = {email: p.user.email, fname: p.user.fname, lname: p.user.lname}
        parr << {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, objective: p.objective, is_team_member: is_team_member, team_owner: team_owner, agency: p.agency, project_type: p.project_type, state: p.state, start_date: start_date, updated_at:updated_at, deadline: deadline, team_size: team_size, resource_count: resource_count, asset_count: asset_count, resources: rarr}
      end
      render json: {org_pid: @current_user.org.pid, projects: parr}
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end
  
  # GET /projects/tvwx
  def show
    p = Project.find_by(pid: params[:id])
    if p
      return head 401 unless @current_user.org == p.org
      narr = []
      p_notes = p.notes ? p.notes : nil
      if p_notes
        p_notes.each do |n|
          created_at = n.created_at ? n.created_at.strftime('%m/%d/%Y') : nil
          author = n.user.fname + ' ' + n.user.lname
          narr << {author: author, pid: n.pid, text: n.text, created_at: created_at}
        end
      end
  
      tarr = []
      p_team = p.team ? p.team : nil
      if p.team
        p_team.each do |u|
          tarr << {user_pid: u.pid, fname: u.fname, lname: u.lname, email: u.email, group_pid: u.group.pid, group_name: u.group.name}
        end
      end
    
      rarr = []
      p_resources = p.resources ? p.resources : nil
      if p_resources
        p_resources.each do |r|
          created_at = r.created_at ? r.created_at.strftime('%m/%d/%Y') : nil
          rarr << {user_pid: p.user.pid, pid: r.pid, name: r.name, objective: r.objective, created_at: created_at}
        end
      end

      aarr = []
      p_assets = p.assets ? p.assets : nil
      if p_assets
        p_assets.each do |a|
          iarr = []
          if a.asset_interactions
            a.asset_interactions.each do |i|
              created_at = i.created_at ? i.created_at.strftime('%m/%d/%Y') : nil
              iarr << {asset_pid: a.pid, prompt: i.prompt, response: i.response, http_status: i.http_status, created_at: created_at}
            end
          end
          aarr << {user_pid: a.user.pid, generator_pid: a.asset_generator.pid, pid: a.pid, objective: a.objective, name: a.name, description: a.description, state: a.state, asset_type: a.asset_type, asset_interactions: iarr}
        end  
      end
      created_at = p.created_at.present? ? p.created_at.strftime('%B %d, %Y') : nil
      start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
      deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
      is_team_member = p.team.include? @current_user
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, objective: p.objective, agency: p.agency, created_at: created_at, start_date: start_date, deadline: deadline, is_team_member: is_team_member, project_type: p.project_type, state: p.state, scope: p.scope, team: tarr, notes: narr, resources: rarr, projects: aarr}
      render json: payload
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /projects
  # asset_pid might be missing, but if it is present, attach the 
  # {"asset_pid": "abc123", "name": "launch pad", "description": "", "agency": "NASA", "project_type": "bid", "state": "active", "start_date": "2025-01-01", "deadline": "2025-03-07", "objective": "win that bid"}
  def create
    p = Project.new(project_params)
    p.org_id = @current_user.org.id
    p.group_id = @current_user.group.id
    p.user_id = @current_user.id
    p.project_type = 'other' unless params[:project_type]
    if p.save
      if params[:asset_pid]
        asset = Asset.find_by(pid: params[:asset_pid])
        p.assets << asset if asset
      end
      p.team << @current_user
      start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
      deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, start_date: start_date, deadline: deadline, objective: p.objective, project_type: p.project_type, state: p.state}
      render json: payload, status: 201
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end
  
  # PUT /projects/abc123
  # {"name": "", "description": "", "agency": "", "type": "", "state": "", "deadline": "", "objective": ""}
  def update
    p = Project.find_by(pid: params[:id])
    # return head 401 unless @current_user.org == p.org
    return head 401 unless (@current_user.org == p.org) && (p.user == @current_user)
    if p
      p.update(project_params)
      start_date = p.start_date ? p.start_date.strftime('%m/%d/%Y') : nil
      deadline = p.deadline ? p.deadline.strftime('%m/%d/%Y') : nil
      payload = {user_pid: p.user.pid, pid: p.pid, name: p.name, description: p.description, start_date: start_date, deadline: deadline, objective: p.objective, project_type: p.project_type, state: p.state}
      render json: payload, status: 200
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # DELETE /projects/abc123
  def destroy
    p = Project.find_by(pid: params[:id])
    return head 401 unless (@current_user.org == p.org) && (p.user == @current_user)
    if p
      p.team.delete_all
      p.notes.delete_all
      p.destroy
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

    # POST /projects/pid/unfolder
  # {"source_folder_pid": "abc"}
  def unfolder
    p = Project.find_by(pid: params[:id])
    if p
      source = Folder.find_by(pid: params[:source_folder_pid])
      FolderProject.where(folder_id: source.id, project_id: p.id).delete_all
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /project/pid/relocate_object
  # {"source_folder_pid": "abc", "destination_folder_pid": "def"}
  # null source is fine (orphan) destination is required!
  def relocate_object
    p = Project.find_by(pid: params[:id])
    if p# && (@current_user.projects.include? p)
      logger.debug '@current_user.projects.include? p'
      logger.debug @current_user.projects.include? p == true
      logger.debug '@current_user.projects.include? p'
      source = Folder.find_by(pid: params[:source_folder_pid])              # optional. if null, is orphan
      destination = Folder.find_by(pid: params[:destination_folder_pid])    # required!
      if destination && (destination.folder_type == 'project') && (destination.scope == p.scope)
        FolderService.new(object: p, source_folder: source, destination_folder: destination).relocate_object
        children = []
        destination.children.each do |f|
          children << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
        end
        action = "relocated project_pid #{p.pid} to folder_pid #{destination.pid}"
        payload = {project_pid: p.pid, folder_pid: destination.pid, user_pid: p.user.pid, folder_name: destination.name, folder_scope: destination.scope, folder_type: destination.folder_type, children: children, action: action}
        render json: payload
      else
        render json: {error: 'Invalid request.'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /resources/pid/create_new_location
  # {"destination_folder_name": "bacon", "source_folder_pid": "def", "parent_folder_pid": "abc"}
  def create_new_location
    s = Folder.find_by(pid: params[:source_folder_pid]) # optional. if null, object is orphan
    p = Folder.find_by(pid: params[:parent_folder_pid]) # optional. if null, folder will be without parent
    pr = Project.find_by(pid: params[:id])
    if pr
      source = s ? s : nil
      parent = p ? p : nil
      folder = FolderService.new(object: pr, source_folder: source, destination_folder_name: params[:destination_folder_name], parent_folder: parent, user: @current_user).create_new_location
      parent_pid = parent ? parent.pid : nil
      action = "created folder_pid: #{folder.pid} to contain project_pid #{pr.pid}"
      payload = {project_pid: pr.pid, folder_pid: folder.pid, user_pid: folder.user.pid, folder_name: folder.name, folder_scope: folder.scope, parent_folder_pid: parent_pid, action: action}
      render json: payload, status: 201
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /projects/:id/add_note
  # {"text": "I am a very important note"}
  def add_note
    p = Project.find_by(pid: params[:id])
    if p
      n = p.notes.create(user_id: @current_user.id, text: params[:text])
      if n
        author = n.user.fname + ' ' + n.user.lname
        created_at = n.created_at ? n.created_at.strftime('%m/%d/%Y') : nil
        payload = {author: author, pid: n.pid, text: n.text, created_at: created_at}
        render json: payload, status: 201
      else
        render json: {error: 'There was an error.'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # GET /projects/id/available_users
  # this is for workgroup members not already on the project
  def available_users
    g = @current_user.group
    p = Project.find_by(pid: params[:id])
    if p && g
      available = g.members - p.team
      uarr = []
      if available
        available.each do |u|
          uarr << {pid: u.pid, fname: u.fname, lname: u.lname, email: u.email}
        end
      end 
      render json: {available_users: uarr}
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end

  # POST /projects/:id/remove_note
  # {"note_pid": "abc123"}
  def remove_note
    p = Project.find_by(pid: params[:id])
    n = Note.find_by(pid: params[:note_pid])
    if p && n && (p.notes.include? n)
      p.notes.delete n
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /projects/:id/request_access
  def request_access
    p = Project.find_by(pid: params[:id])
    if p && p.org_id == @current_user.org.id
      UserMailer.with(user: @current_user, project: p).request_project_access.deliver_now
      render json: {message: "Project Access Request generated"}, status: 201
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /projects/:id/add_team_member
  # {"user_pid":"abc123"}
  def add_team_member
    logger.debug('++++++++++++++++++++++++++++++')
    logger.debug(params.inspect)
    logger.debug('++++++++++++++++++++++++++++++')
    p = Project.find_by(pid: params[:id])
    if p && p.org_id == @current_user.org.id
      u = User.find_by(pid: params[:user_pid])
      if u
        p.team << u unless p.team.include? u
        render json: {project_pid: p.pid, message: "Member #{u.pid} has been added"}, status: 201
      else
        render json: {error: 'Not found.'}, status: 404
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /projects/:id/remove_team_member
  # {"user_pid":"abc123"}
  def remove_team_member
    p = Project.find_by(pid: params[:id])
    if p && p.org_id == @current_user.org.id
      u = User.find_by(pid: params[:user_pid])
      if u
        if u != p.user
          p.team.delete u if p.team.include?(u)
        else
          render json: {error: 'Project owner cannot be removed'}, status: 401 and return
        end
        render json: {project_pid: p.pid, message: "Member #{u.pid} has been removed"}, status: 201
      else
        render json: {error: 'Not found.'}, status: 404
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # GET /projects/:pid/resources
  # Two arrays, attached and available
  def resources
    o = @current_user.org
    p = Project.find_by(pid: params[:id])
    attached = p.resources
    # available = o.resources - p.resources
    atarr = []
    # avarr = []
    attached.each do |atr|
      atarr << {org_pid: o.pid, pid: atr.pid, name: atr.name, description: atr.description, objective: atr.objective, source_url: atr.source_url, state: atr.state}
    end
    # available.each do |avr|
    #   avarr << {org_pid: o.pid, pid: avr.pid, name: avr.name, description: avr.description, objective: avr.objective, source_url: avr.source_url, state: avr.state}  
    # end
    render json: {project_pid: p.pid, attached: atarr}
    # render json: {project_pid: p.pid, available: avarr, attached: atarr}
  end

  # POST /projects/:id/attach_resource
  # {"resource_pid":"abc123"}
  def attach_resource
    p = Project.find_by(pid: params[:id], org_id: @current_user.org.id)
    if p && p.org_id == @current_user.org.id
      r = Resource.find_by(pid: params[:resource_pid])
      if r && r.org_id == @current_user.org.id
        p.resources << r unless p.resources.include? r
        render json: {project_pid: p.pid, message: "Resource #{r.pid} has been attached"}, status: 201
      else
        render json: {error: 'Not found.'}, status: 404
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # POST /projects/pid/detach_resource
  # {"resource_pid":"abc123"}
  def detach_resource
    p = Project.find_by(pid: params[:id])
    if p
      r = Resource.find_by(pid: params[:resource_pid])
      if r && r.org_id == @current_user.org.id
        p.resources.delete r if p.resources.include? r
        render json: {project_pid: p.pid, message: "Resource #{r.pid} has been detached"}, status: 201
      else
        render json: {error: 'Not found.'}, status: 404
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /projects/pid/detach_asset
  # {"asset_pid":"abc123"}
  def detach_asset
    p = Asset.find_by(pid: params[:id])
    if p
      r = Resource.find_by(pid: params[:resource_pid])
      if r && r.org_id == @current_user.org.id
        p.resources.delete r if p.resources.include? r
        render json: {project_pid: p.pid, message: "Asset #{a.pid} has been detached"}, status: 201
      else
        render json: {error: 'Not found.'}, status: 404
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

    def project_params
      params.require(:project).permit(:scope, :user_pid, :name, :description, :agency, :project_type, :state, :start_date, :deadline, :objective, :text, :asset_pid)
    end

end

#   Parameters: {"name"=>"name", "description"=>"desc", "agency"=>"agency", "type"=>"type", "start_date"=>"2023-01-16", "deadline"=>"2023-01-26", "state"=>"active", "objective"=>"obj", "project"=>{"state"=>"active", "name"=>"name", "description"=>"desc", "objective"=>"obj", "agency"=>"agency", "start_date"=>"2023-01-16", "deadline"=>"2023-01-26"}}