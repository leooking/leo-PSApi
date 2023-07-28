# frozen_string_literal: true

class AssetzController < ApplicationController

  rescue_from ActionController::UnpermittedParameters, with: :create

  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /assetz/recent
  def recent
    assets = Asset.includes(:asset_interactions).where(user_id: @current_user.id, scope: 'mine').order('asset_interactions.created_at ASC').limit(10)
    aarr = []
    assets.each do |a|
      latest_interaction = a.asset_interactions.order(created_at: :desc).pluck(:created_at).first.iso8601# strftime('%m-%d-%y %H:%M')
      aarr << {pid: a.pid, name: a.name, scope: a.scope, interactions: a.asset_interactions.count, latest_interaction: latest_interaction}
    end
    render json: {user_pid: @current_user.pid, recent_assets: aarr}
  end

  # GET /assetz2?search=foo%20bar&project_pid=abc123 << search and project is optional
  def index2

    p = Project.find_by(pid: params[:project_pid])
    if p && (p.team.include? @current_user)
      assets = p.assets
    else
      assets = @current_user.org.org_assets
    end

    # filter assets
    if params[:search]
      search_params = params[:search]
      assets = assets.full_asset_search(search_params)
    end
    
    if assets
      root_shared_folders = Folder.includes(:assets).where(org_id: @current_user.org.id, scope: 'group', parent_id: nil, folder_type: 'asset')
      root_private_folders = Folder.includes(:assets).where(org_id: @current_user.org.id, scope: 'mine', parent_id: nil, folder_type: 'asset')
  
      rsf = []
      rpf = []
  
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
              f.assets.each do |a|
                parr = []
                projs = a.projects
                projs.each do |p|
                  parr << {pid: p.pid, name: p.name, scope: p.scope}  
                end
                f = a.folders ? a.folders.first : nil
                parent_pid = f && f.parent ? f.parent.pid : nil
                folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
                last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
                tr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: scope, last_interaction_at: last_interaction_at, projects: parr} if a.scope == 'group'
              end
              t_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, assets: tr_arr}
            end
            sr_arr = []
            f.assets.each do |a|
              parr = []
              projs = a.projects
              projs.each do |p|
                parr << {pid: p.pid, name: p.name, scope: p.scope}  
              end
              f = a.folders ? a.folders.first : nil
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
              last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
              sr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if a.scope == 'group'
            end
            s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, assets: sr_arr}
          end
          fr_arr = []
          f.assets.each do |a|
            parr = []
            projs = a.projects
            projs.each do |p|
              parr << {pid: p.pid, name: p.name, scope: p.scope}  
            end
            f = a.folders ? a.folders.first : nil
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
            last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
            fr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if a.scope == 'group'
          end
          f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, assets: fr_arr}
        end
        rr_arr = []
        f.assets.each do |a|
          parr = []
          projs = a.projects
          projs.each do |p|
            parr << {pid: p.pid, name: p.name, scope: p.scope}  
          end
          f = a.folders ? a.folders.first : nil
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
          last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
          rr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if a.scope == 'group'
        end
        rsf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, assets: rr_arr}
      end
  
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
              f.assets.where(scope: 'mine', user_id: @current_user.id).each do |a|
                parr = []
                projs = a.projects
                projs.each do |p|
                  parr << {pid: p.pid, name: p.name, scope: p.scope}  
                end
                f = a.folders ? a.folders.first : nil
                parent_pid = f && f.parent ? f.parent.pid : nil
                folder = f ? {pid: f.pid} : nil
                last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
                tr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if (f.scope == 'mine') && (a.user == @current_user)
              end
              t_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, assets: tr_arr}
            end
            sr_arr = []
            f.assets.where(scope: 'mine', user_id: @current_user.id).each do |a|
              parr = []
              projs = a.projects
              projs.each do |p|
                parr << {pid: p.pid, name: p.name, scope: p.scope}  
              end
              f = a.folders ? a.folders.first : nil
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid} : nil
              last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
              sr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if (f.scope == 'mine') && (a.user == @current_user)
            end
            s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, assets: sr_arr}
          end
          fr_arr = []
          f.assets.where(scope: 'mine', user_id: @current_user.id).each do |a|
            parr = []
            projs = a.projects
            projs.each do |p|
              parr << {pid: p.pid, name: p.name, scope: p.scope}  
            end
            f = a.folders ? a.folders.first : nil
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid} : nil
            last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
            fr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if (f.scope == 'mine') && (a.user == @current_user)
          end
          f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, assets: fr_arr}
        end
        rr_arr = []
        f.assets.where(scope: 'mine', user_id: @current_user.id).each do |a|
          parr = []
          projs = a.projects
          projs.each do |p|
            parr << {pid: p.pid, name: p.name, scope: p.scope}
          end
          f = a.folders ? a.folders.first : nil
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid} : nil
          last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
          rr_arr << {user_pid: a.user.pid, pid: a.pid, folder: folder, name: a.name, scope: a.scope, last_interaction_at: last_interaction_at, projects: parr} if (f.scope == 'mine') && (a.user == @current_user)
        end
        rpf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, assets: rr_arr}
      end
  
      shared_orphan_assets = []
  
      assets.where(scope: 'group').each do |a|
        interactions_count = !a.asset_interactions.blank? ? a.asset_interactions.count : nil
        created_at = a.created_at ? a.created_at.strftime('%m/%d/%Y') : nil
        asset_name = a.name ? a.name : nil
        generator_name = a.asset_generator ? a.asset_generator.name : nil
        parr = []
        projs = a.projects
        projs.each do |p|
          parr << {pid: p.pid, name: p.name, scope: p.scope}  
        end
        last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
        shared_orphan_assets << {user_pid: a.user.pid, pid: a.pid, name: asset_name, generator_name: generator_name, scope: a.scope, interactions_count: interactions_count, last_interaction_at: last_interaction_at, projects: parr} if a.orphan? && a.scope == 'group'
      end

      private_orphan_assets = []
      assets.where(scope: 'mine', user_id: @current_user.id).each do |a|
        interactions_count = !a.asset_interactions.blank? ? a.asset_interactions.count : nil
        created_at = a.created_at ? a.created_at.strftime('%m/%d/%Y') : nil
        asset_name = a.name ? a.name : nil
        generator_name = a.asset_generator ? a.asset_generator.name : nil
        parr = []
        projs = a.projects
        projs.each do |p|
          parr << {pid: p.pid, name: p.name, scope: p.scope}  
        end
        last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
        private_orphan_assets << {user_pid: a.user.pid, pid: a.pid, name: asset_name, generator_name: generator_name, scope: a.scope, interactions_count: interactions_count, last_interaction_at: last_interaction_at, projects: parr} if a.orphan? && a.scope == 'mine'
      end
    end
    render json: {org_pid: @current_user.org.pid, shared_orphan_assets: shared_orphan_assets, private_orphan_assets: private_orphan_assets, shared_folders: rsf, private_folders: rpf}
  end

  # GET /assetz?project_pid=abc123
  def index
    p = Project.find_by(pid: params[:project_pid])
    if p
      render json: {error: 'Not found.'}, status: 404 and return unless p
      assets = Asset.where(project_id: p.id).all
      aarr = []
      if assets && (p.team.include? @current_user)
        assets.each do |a|
          parr = []
          projs = a.projects
          projs.each do |p|
            parr << {pid: p.pid, name: p.name, scope: p.scope}  
          end
          interactions_count = !a.asset_interactions.blank? ? a.asset_interactions.count : nil
          created_at = a.created_at ? a.created_at.strftime('%m/%d/%Y') : nil
          last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
          aarr << {user_pid: a.user.pid, pid: a.pid, name: a.name, description: a.description, objective: a.objective, generator_name: a.asset_generator.name, scope: a.scope, state: a.state, asset_type: a.asset_type, interactions_count: interactions_count, created_at: created_at, last_interaction_at: last_interaction_at, projects: parr}
        end
        render json: {project_pid: p.pid, assets: aarr}
      else
        render json: {error: 'There was an error'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # GET /assetz/:pid?revision_check=false
  def show
    revision_check = params[:revision_check].present? ? params[:revision_check] : true
    a = Asset.find_by(pid: params[:id])
    if a
      return head 401 unless @current_user.org == a.user.org
      ints = a.asset_interactions
      if revision_check == true
        a.asset_revisions.each do |revision|
          if revision.asset_interactions.blank? || revision.asset_interactions.count.zero?
            revision.destroy
          end
        end
      end
      rvs = a.asset_revisions
      b = a.asset_revisions.order(created_at: :DESC).first
      iarr = []
      ints.each do |i|
        citations = []
        if i.citation_data
          i.citation_data.each do |d|
            resource = Resource.find_by(pid: d['resource_pid'])
            citations << {type: 'resource', resource_pid: resource.pid, relevant_chunk: d['relevant_chunk'], resource_name: resource.name} if resource
          end
        elsif i.third_party_data
          i.third_party_data.each do |d|
            if d['qdrant_collection'] == 'sam-gov-opportunities'
              citations << {type: 'non-resource', link: d['payload']['Link']}
            elsif d['qdrant_collection'] == 'usaspending-gov-notices'
              citations << {type: 'non-resource', link: d['payload']['usaspending_permalink']}
            end
          end
        end
        created_at = i.created_at ? i.created_at.strftime('%m/%d/%Y') : nil
        revision_pid = i.asset_revision ? i.asset_revision.pid : nil
        iarr << {asset_pid: a.pid, pid: i.pid, prompt: i.prompt, response: i.response, action: i.action, citations: citations, thumbs: i.thumbs, http_status: i.http_status, token_cost: i.token_cost, use_my_resources: i.use_my_resources, use_ext_resources: i.use_ext_resources, use_premium_resources: i.use_premium_resources, revision_pid: revision_pid, created_at: created_at}
      end
      parr = []
      projs = @current_user.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      rarr = []
      rvs.each do |r|
        rvs_ids = get_rvs_ids(rvs, r.parent_id)
        rvs_ids.push(r.pid)
        rarr << {revision_pid: r.pid, user: r.user.name, created_at: r.created_at, rvs_ids: rvs_ids}
      end
      a.asset_generator.sidebar_instruction
      resumable = a.asset_generator.resumable
      generator_type = a.asset_generator.generator_type
      generator_max_tokens = a.asset_generator.window_size
      my_resources_visible = a.asset_generator.my_resources_visible
      ext_resources_visible = a.asset_generator.ext_resources_visible
      prompt_assistant_visible = a.asset_generator.prompt_assistant_visible
      prompt_builder_visible = a.asset_generator.prompt_builder_visible
      user_guide_url = a.asset_generator.user_guide_url
      revision_pid = b ? b.pid : nil
      created_at = a.created_at ? a.created_at.strftime('%m/%d/%Y') : nil
      last_autosave = a.last_autosave ? a.last_autosave.plain_text : nil
      last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
      # JKJK asset jailbreak note: project_pid needed to be deprecated
      # payload = {user_pid: a.user.pid, project_pid: p.pid, pid: a.pid, resumable: resumable, user_guide_url: user_guide_url, prompt_assistant_visible: prompt_assistant_visible, my_resources_visible: my_resources_visible, ext_resources_visible: ext_resources_visible, generator_type: generator_type, generator_max_tokens: generator_max_tokens, name: a.name, description: a.description, objective: a.objective, generator_name: a.asset_generator.name, generator_pid: a.asset_generator.pid, convo_preface: a.asset_generator.convo_preface, sidebar_instruction: a.asset_generator.sidebar_instruction, scope: a.scope, state: a.state, created_at: created_at, total_tokens: a.total_tokens, last_autosave: last_autosave, interactions: iarr}  
      payload = {user_pid: a.user.pid, user_name: a.user.name, pid: a.pid, resumable: resumable, user_guide_url: user_guide_url, prompt_builder_visible: prompt_builder_visible, prompt_assistant_visible: prompt_assistant_visible, my_resources_visible: my_resources_visible, ext_resources_visible: ext_resources_visible, generator_type: generator_type, generator_max_tokens: generator_max_tokens, name: a.name, description: a.description, objective: a.objective, generator_name: a.asset_generator.name, generator_pid: a.asset_generator.pid, convo_preface: a.asset_generator.convo_preface, sidebar_instruction: a.asset_generator.sidebar_instruction, scope: a.scope, state: a.state, created_at: created_at, last_interaction_at: last_interaction_at, total_tokens: a.total_tokens, last_autosave: last_autosave, interactions: iarr, revision_pid: revision_pid, revisions: rarr}  
      render json: payload
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  def get_rvs_ids(rvs, parent_id)
    rvs_ids = []
    rvs.each do |r|
      if r.id == parent_id
        rvs_ids << r.pid
        rvs_ids += get_rvs_ids(rvs, r.parent_id)
      end
    end
    rvs_ids
  end

  # POST /assetz
  # {
  #   "asset_generator_pid": "49xj",
  #   "project_pid": "mvlk",
  #   "name": "this is my name",
  #   "objective": "This is my objective",
  #   "scope": "org",
  # }
  def create
    u = @current_user
    g = AssetGenerator.find_by(pid: params[:asset_generator_pid])
    p = Project.find_by(pid: params[:project_pid])
    # Project is optional so handle nil errors
    if p
      project_id = p.id
      project_pid = p.pid
    else
      project_id = nil
      project_pid = nil
    end
    # project_id = p ? p.id : nil
    # project_pid = p ? p.pid : nil
    if g
      # render json: {message: 'Hooray, that was a successful POST'} and return
      a = Asset.new(user_id: u.id, project_id: project_id, asset_generator_id: g.id, name: params[:name], objective: params[:objective], scope: params[:scope], state: 'requested')
      if a.save
        parr = []
        projs = @current_user.projects
        projs.each do |p|
          parr << {pid: p.pid, name: p.name, scope: p.scope}  
        end
        
        #  AssetRevision Create
        b = AssetRevision.new(user_id: u.id, project_id:project_id, asset_generator_id:g.id, asset_id:a.id)
        if b.save
          payload = {project_pid: project_pid, asset_generator_pid: g.pid, pid: a.pid, generator_type: g.generator_type, generator_pid: g.pid, generator_name: g.name, card_description: g.card_description, convo_preface: g.convo_preface, sidebar_instruction: g.sidebar_instruction, name: a.name, objective: a.objective, state: a.state, scope: a.scope, projects: parr, asset_revision_id: b.pid}
        end
        render json: payload, status: 202 # accepted
      else
        render json: {error: 'There was an errorr (CODE: 001).'}, status: 400
      end
    else
      render json: {error: 'There was an errorr (CODE: 002).'}, status: 400
    end
  end

  # Save asset to existing project
  # POST /assetz/pid/set_project_attachments
  # {"project_pids": ["abc","bcd","cde"]}
  def set_project_attachments
    a = Asset.find_by(pid: params[:id])
    if a && (@current_user.org.org_assets.include? a)
      params[:project_pids].each do |pid|
        p = Project.find_by(pid: pid)
        if a.scope == p.scope
          a.projects << p unless a.projects.include? p
        else
          render json: {error: 'scope mismatch!'}, status: 400 and return
        end
      end
      action = "Attached asset pid #{a.pid} to project pids #{params[:project_pids]}"
      payload = {asset_pid: a.pid, project_pids: params[:project_pids], action: action}
      render json: payload and return
    else
      render json: {error: 'asset or org error'}, status: 400
    end
  end

  # POST /assetz/pid/convert_to_org_scope
  # TODO refactor to group or deprecate
  # body is optional
  # def convert_to_org_scope
  #   a = Asset.find_by(pid: params[:id])
  #   if a
  #     if a.projects
  #       a.projects.each do |p|
  #         p.assets.delete a if p.scope == 'mine'
  #       end
  #     end
  #     if a.folders
  #       a.folders.each do |f|
  #         f.assets.delete a if f.scope == 'mine'
  #       end
  #     end
  #     a.update(scope: 'org')
      
  #     payload = {asset_generator_pid: g.pid, pid: a.pid, generator_type: a.asset_generator.generator_type, generator_pid: a.asset_generator.pid, generator_name: a.asset_generator.name, card_description: a.asset_generator.card_description, convo_preface: a.asset_generator.convo_preface, sidebar_instruction: a.asset_generator.sidebar_instruction, name: a.name, objective: a.objective, state: a.state, scope: a.scope, projects: []}
  #     render json: payload, status: 200
  #   else
  #     render json: {error: 'Not found.'}, status: 404
  #   end
  # end

  # POST /assetz/pid/unfolder
  # {"source_folder_pid": "abc"}
  def unfolder
    a = Asset.find_by(pid: params[:id])
    source = Folder.find_by(pid: params[:source_folder_pid])
    if a
      AssetFolder.where(folder_id: source.id, asset_id: a.id).delete_all
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /assetz/pid/relocate_object
  # {"source_folder_pid": "abc", "destination_folder_pid": "def"}
  # null source is fine (orphan) destination is required!
  def relocate_object
    a = Asset.find_by(pid: params[:id])
    if a && (@current_user.org.org_assets.include? a)
      source = Folder.find_by(pid: params[:source_folder_pid])              # optional. if null, is orphan
      destination = Folder.find_by(pid: params[:destination_folder_pid])    # required!
      if destination && (destination.folder_type == 'asset') && (destination.scope == a.scope)
        FolderService.new(object: a, source_folder: source, destination_folder: destination).relocate_object
        children = []
        destination.children.each do |f|
          children << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
        end
        action = "relocated asset_pid #{a.pid} to folder_pid #{destination.pid}"
        payload = {asset_pid: a.pid, folder_pid: destination.pid, user_pid: a.user.pid, folder_name: destination.name, folder_scope: destination.scope, folder_type: destination.folder_type, children: children, action: action}
        render json: payload
      else
        render json: {error: 'Invalid request.'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /assetz/pid/create_new_location
  # {"destination_folder_name": "bacon", "source_folder_pid": "def", "parent_folder_pid": "abc"}
  def create_new_location
    s = Folder.find_by(pid: params[:source_folder_pid]) # optional. if null, object is orphan
    p = Folder.find_by(pid: params[:parent_folder_pid]) # optional. if null, folder will be without parent
    a = Asset.find_by(pid: params[:id])
    if a
      source = s ? s : nil
      parent = p ? p : nil
      folder = FolderService.new(object: a, source_folder: source, destination_folder_name: params[:destination_folder_name], parent_folder: parent, user: @current_user).create_new_location
      parent_pid = parent ? parent.pid : nil
      action = "created folder_pid: #{folder.pid} to contain asset_pid #{a.pid}"
      payload = {asset_pid: a.pid, folder_pid: folder.pid, user_pid: folder.user.pid, folder_name: folder.name, folder_scope: folder.scope, parent_folder_pid: parent_pid, action: action}
      render json: payload, status: 201
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # Save asset to existing project
  # POST /assetz/pid/attach_to_project
  # {"project_pid": "abc123"}
  def attach_to_project
    a = Asset.find_by(pid: params[:id])
    p = Project.find_by(pid: params[:project_pid])
    if a && p && (p.org == @current_user.org)
      p.assets << a unless p.assets.include? a
      render json: {message: "Asset saved to project: “#{p.name}"}
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # Create New Revision when Resume Existing Asset
  # POST /assetz/pid/create_revision
  # {
  #   "user_pid": "dfedf",
  #   "generator_pid": "fdcdre"
  #   "parent_revision": "rrrr"
  # }
  def create_revision
    u = @current_user
    a = Asset.find_by(pid: params[:id])
    g = AssetGenerator.find_by(pid: params[:generator_pid])
    p = AssetRevision.find_by(pid:params[:parent_revision]) if params[:parent_revision]
    if a && u
      if p
        b = AssetRevision.new(user_id: u.id, asset_generator_id: g.id, asset_id:a.id, parent_id:p.id, ignore:true)
      else
        b = AssetRevision.new(user_id: u.id, asset_generator_id: g.id, asset_id:a.id)
      end
      b.save
      render json: {message: "New Revision Successfully Created!", success: true}
    else
      render json: {error: 'Not found.'}, status: 404
    end

  end

  # POST /assetz/:pid/autosave
  # {
  #   "current_content": "big ol chunk 'o markdown"
  # }
  def autosave
    a = Asset.find_by(pid: params[:id])
    if a
      autosave = AssetAutosave.new(asset_id: a.id, user_id: @current_user.id, plain_text: params[:current_content])
      if autosave.save
        render json: {message: 'Current content autosaved'}, status: :ok and return
      else
        render json: {error: 'Operation failed!'}, status: 400 and return
      end
    else
      render json: {error: 'Not found.'}, status: 404 and return
    end
  end

  # POST /assetz/:pid/interaction
  # {
    #   "chains": true,               # <<<< this is for IB2
    #   "ib2_action": "add-detail",       # <<<< this is for IB2
    #   "use_my_resources": true,
    #   "use_ext_resources": true,
    #   "use_premium_resources": true, (when generator type is shipley, the toggle appears)
    #   "shared_resources": ["far-pdf", "dfars-pdf", sam_dot_gov", "usa_spending"] # one or two or twenty, array of strings
    #       ^^ These are defined as a constant on the API ^^
    #   "resource_pids": ["abc", "hij"],
    #       OR MAYBE:
    #   "resource_pids": ["shipley_proposal_guide", "shipley_capture_guide"], (else empty arrayt for both!)
    #   "inputs": {"industry": "foo", "agency": "bar"},
    #   "cosine_threshold": 0.5
    #   "citations": [{"resource_name": "Lohfeld 10 Steps to High Scoring Proposals", "resource_pid": "ten_steps", "relevant_chunk": "blah blah blah citation text string"}]
    # }
  # POST /assetz/:pid/interaction
  
  def interaction
    a = Asset.find_by(pid: params[:id])
    b = AssetRevision.find_by(pid: params[:revision_pid])
    revision_id = b ? b.id : nil
    g = a.asset_generator
    if a && g
      @ai = AssetInteraction.create(
        use_my_resources:       params[:use_my_resources],
        use_ext_resources:      params[:use_ext_resources],
        use_premium_resources:  params[:use_premium_resources],
        prompt:                 params[:prompt], 
        response:               params[:response],
        token_cost:             params[:token_cost],
        citation_data:          params[:citations],
        asset_revision_id:      revision_id,
        asset_generator_id:     g.id,
        asset_id:               a.id, 
        user_id:                @current_user.id
        )
      if @ai

        # keep track of tokens used
        cost = @ai.token_cost ? @ai.token_cost : 0
        total = a.total_tokens ? a.total_tokens : 0
        new_total = cost + total

        if a.total_tokens.blank?
          a.update(total_tokens: cost)
        else
          a.update(total_tokens: new_total)
        end

        render json: {message: "Successfully created asset_interaction pid #{@ai.pid} for asset pid #{a.pid}"}

        # old:
        # payload = {user_pid: a.user.pid, pid: a.pid, resumable: resumable, user_guide_url: user_guide_url, prompt_assistant_visible: prompt_assistant_visible, my_resources_visible: my_resources_visible, ext_resources_visible: ext_resources_visible, generator_type: generator_type, generator_max_tokens: generator_max_tokens, name: a.name, description: a.description, objective: a.objective, generator_name: a.asset_generator.name, generator_pid: a.asset_generator.pid, convo_preface: a.asset_generator.convo_preface, sidebar_instruction: a.asset_generator.sidebar_instruction, scope: a.scope, state: a.state, created_at: created_at, last_interaction_at: last_interaction_at, total_tokens: a.total_tokens, last_autosave: last_autosave, interactions: iarr}  
      else
        render json: {error: 'there was an error'}, status: 400 and return
      end

    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  def interaction0
    a = Asset.find_by(pid: params[:id])
    if a
      if params[:inputs] && a.asset_generator.generator_type == 'multi' # aka multi-page aka intellibid
        prompt = params[:prompt]
        inputs = params[:inputs].to_unsafe_h.symbolize_keys
        str = a.asset_generator.dynamic_preamble
        preamble = str % inputs unless params[:chains] == true # flows the inputs into the preamble placeholders 
        prompt = prompt
      else
        preamble  = a.asset_generator.preamble
        prompt    = params[:prompt]
      end

      action = params[:ib2_action]
      # create interaction record
      @ai = AssetInteraction.create(
        action:               action,
        use_my_resources:     params[:use_my_resources],
        use_ext_resources:    params[:use_ext_resources],
        use_premium_resources: params[:use_premium_resources],
        preamble:             preamble,
        prompt:               prompt, 
        asset_generator_id:   a.asset_generator_id,
        asset_id:             a.id, 
        user_id:              a.user_id
        )
      if @ai

        logger.debug 'param   param   param'
        logger.debug params[:use_my_resources]
        logger.debug 'param   param   param'
        logger.debug params[:resource_pids]
        logger.debug 'param   param   param'
        logger.debug params[:use_ext_resources]
        logger.debug 'param   param   param'
        logger.debug params[:shared_resources]
        logger.debug 'param   param   param'

        inputs = params[:inputs]
        if params[:chains] == true
          ChainsService.new(
            asset_interaction: @ai,
            use_my_resources: params[:use_my_resources], 
            use_ext_resources: params[:use_ext_resources], 
            use_premium_resources: params[:use_premium_resources], 
            resource_pids: params[:resource_pids],
            inputs: params[:inputs].to_unsafe_h,
            action: action,
            cosine_threshold: params[:cosine_threshold]
          ).chat
        else
          LlmService.new(
            asset_interaction: @ai, 
            use_my_resources: params[:use_my_resources], 
            use_ext_resources: params[:use_ext_resources], 
            use_premium_resources: params[:use_premium_resources], 
            resource_pids: params[:resource_pids],
            shared_resources: params[:shared_resources], 
            cosine_threshold: params[:cosine_threshold]
            ).call
        end

        cost = @ai.token_cost ? @ai.token_cost : 0
        total = a.total_tokens ? a.total_tokens : 0
        new_total = cost + total

        if a.total_tokens.blank?
          a.update(total_tokens: cost)
        else
          a.update(total_tokens: new_total)
        end

        ints = a.asset_interactions.order(:created_at).reload

        iarr = []
        ints.each do |i|
          citations = []
          if i.citation_data
            i.citation_data.each do |d|
              resource = Resource.find_by(pid: d['resource_pid'])
              citations << {type: 'resource', resource_pid: resource.pid, relevant_chunk: d['relevant_chunk'], link_text: resource.name} if resource
            end
          elsif i.third_party_data
            i.third_party_data.each do |d|
              if d['qdrant_collection'] == 'sam-gov-opportunities'
                citations << {type: 'non-resource', link: d['payload']['Link']}
              elsif d['qdrant_collection'] == 'usaspending-gov-notices'
                citations << {type: 'non-resource', link: d['payload']['usaspending_permalink']}
              end
            end
          end
          created_at = i.created_at ? i.created_at.strftime('%m/%d/%Y') : nil
          iarr << {pid: i.pid, preamble: i.preamble, prompt: i.prompt, response: i.response, action: i.action, citations: citations, thumbs: i.thumbs, http_status: i.http_status, token_cost: i.token_cost, use_my_resources: i.use_my_resources, use_ext_resources: i.use_ext_resources, use_premium_resources: i.use_premium_resources, created_at: created_at}
        end
        
        # JKJK jailbreak note. had to deprecate project_pid in the respone payload
        # project_pid = a.project ? a.project.pid : nil
        payload = {
          asset_generator_name:   @ai.asset_generator.name,
          asset_name:             a.name,
          asset_objective:        a.objective,
          # project_pid:            project_pid, 
          interactions:           iarr
        }
        render json: payload
      else
        render json: {error: 'There was an errorr (CODE: 003).'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # PUT /assetz/:pid
  # Let them add name description stuff at this point
  # {"name": "this is my name"}
  def update
    a = Asset.find_by(pid: params[:id])
    if a
      a.update(asset_params)
      p = a.project ? a.project : nil
      ints = a.asset_interactions
      iarr = []
      ints.each do |i|
        citations = []
        if i.citation_data
          i.citation_data.each do |d|
            resource = Resource.find_by(pid: d['resource_pid'])
            citations << {type: 'resource', resource_pid: resource.pid, relevant_chunk: d['relevant_chunk'], link_text: resource.name} if resource
          end
        elsif i.third_party_data
          i.third_party_data.each do |d|
            if d['qdrant_collection'] == 'sam-gov-opportunities'
              citations << {type: 'non-resource', link: d['payload']['Link']}
            elsif d['qdrant_collection'] == 'usaspending-gov-notices'
              citations << {type: 'non-resource', link: d['payload']['usaspending_permalink']}
            end
          end
        end
        created_at = i.created_at ? i.created_at.strftime('%m/%d/%Y') : nil
        iarr << {asset_pid: a.pid, prompt: i.prompt, response: i.response, action: i.action, citations: citations, thumbs: i.thumbs, http_status: i.http_status, token_cost: i.token_cost, use_my_resources: i.use_my_resources, use_ext_resources: i.use_ext_resources, use_premium_resources: i.use_premium_resources, created_at: created_at}
      end
      parr = []
      projs = @current_user.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      if p 
        project_pid = p.pid
      else
        project_pid = nil
      end
      created_at = a.created_at ? a.created_at.strftime('%m/%d/%Y') : nil
      last_interaction_at = !a.asset_interactions.blank? ? a.asset_interactions.last.updated_at.strftime('%m/%d/%Y') : nil
      payload = {
        user_pid: a.user.pid, 
        project_pid: project_pid, 
        pid: a.pid, 
        generator_pid: a.asset_generator.pid,
        name: a.name, description: a.description, objective: a.objective, generator_name: a.asset_generator.name, scope: a.scope, state: a.state, created_at: created_at, total_tokens: a.total_tokens, last_interaction_at: last_interaction_at, interactions: iarr}  
      render json: payload
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # DELETE /assetz/:pid
  def destroy
    a = Asset.find_by(pid: params[:id])
    if a
      # detach from projects by deleting join records
      AssetProject.where(asset_id: a.id).delete_all
      a.destroy
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  private
  
    def asset_params
      params.permit(:use_my_resources, :use_ext_resources, :use_premium_resources, :asset_pids, :action, :current_content, :scope, :use_my_resources, :cosine_threshold, :token_cost, :total_tokens, :asset, :pid, :asset_generator_pid, :project_pid, :objective, :name, :description, :frozen, :state, :prompt, :inputs=> [])
    end

  end
