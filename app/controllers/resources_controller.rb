# frozen_string_literal: true

class ResourcesController < ApplicationController
  require "google/cloud/storage"
  include Authentication
  include UrlValidator
  # include VexNotifier

  before_action :require_api_key
  before_action :require_sign_in, except: [:resource_crawl]
  before_action :wtf_rails, only: [:create]
  before_action :bulk_resource_params, only: [:bulk_upload]

  # GET /resources2?pdf_only=true
  # GET /resources2 # send all
  def index2
    if params[:pdf_only]
      # FIXME see Resource.pdf_only scope
      #  usage gives strange error "(Object doesn't support #inspect)"
      # This is why this hack is used instead
      resources = []
      query = Resource.where(org_id: @current_user.org.id)
      query = query.search_full_text(params[:q]) if !params[:q].blank?
      query.each do |r|
        resources << r if r.data_asset && r.data_asset['content_type'] == 'application/pdf'
      end
    else
      query = Resource
      query = query.where(org_id: @current_user.org.id)
      query = query.search_full_text(params[:q]) if !params[:q].blank?
      query = query.page(params[:page]).per(params[:per]) if !params[:page].blank? || !params[:per].blank?
      resources = query
    end

    root_shared_folders = Folder.includes(:resources).where(org_id: @current_user.org.id, scope: 'group', parent_id: nil, folder_type: 'resource')
    root_private_folders = Folder.includes(:resources).where(org_id: @current_user.org.id, scope: 'mine', parent_id: nil, folder_type: 'resource')

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
            f.resources.each do |r|
              parr = []
              projs = r.projects
              projs.each do |p|
                parr << {pid: p.pid, name: p.name, scope: p.scope}  
              end
              if r.data_asset.blank?
                file_link = nil
                link_seconds = nil
                file_name = nil
              else
                file_name     = r.data_asset['filename']
                link_seconds  = 300
                file_link     = nil
              end
              f = r.folders ? r.folders.first : nil
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid} : nil
              
              tr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%B %d, %Y'), projects: parr} if r.scope != 'mine'
            end
            t_arr << {pid: f.pid, name: f.name, resources: tr_arr}
          end
          sr_arr = []
          f.resources.each do |r|
            parr = []
            projs = r.projects
            projs.each do |p|
              parr << {pid: p.pid, name: p.name, scope: p.scope}  
            end
            if r.data_asset.blank?
              file_link = nil
              link_seconds = nil
              file_name = nil
            else
              file_name     = r.data_asset['filename']
              link_seconds  = 300
              file_link     = nil
            end
            f = r.folders ? r.folders.first : nil
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid} : nil
            
            sr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if r.scope != 'mine'
          end
          s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, resources: sr_arr}
        end
        fr_arr = []
        f.resources.each do |r|
          parr = []
          projs = r.projects
          projs.each do |p|
            parr << {pid: p.pid, name: p.name, scope: p.scope}  
          end
          if r.data_asset.blank?
            file_link = nil
            link_seconds = nil
            file_name = nil
          else
            file_name     = r.data_asset['filename']
            link_seconds  = 300
            file_link     = nil
          end
          f = r.folders ? r.folders.first : nil
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid} : nil
          
          fr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if r.scope != 'mine'
        end
        f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, resources: fr_arr}
      end
      rr_arr = []
      f.resources.each do |r|
        parr = []
        projs = r.projects
        projs.each do |p|
          parr << {pid: p.pid, name: p.name, scope: p.scope}  
        end
        if r.data_asset.blank?
          file_link = nil
          link_seconds = nil
          file_name = nil
        else
          file_name     = r.data_asset['filename']
          link_seconds  = 300
          file_link     = nil
        end
        f = r.folders ? r.folders.first : nil
        parent_pid = f && f.parent ? f.parent.pid : nil
        folder = f ? {pid: f.pid} : nil
        
        rr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if r.scope != 'mine'
      end
      rsf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, resources: rr_arr}
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
            f.resources.where(scope: 'mine', user_id: @current_user.id).each do |r|
              parr = []
              projs = r.projects
              projs.each do |p|
                parr << {pid: p.pid, name: p.name, scope: p.scope}  
              end
              if r.data_asset.blank?
                file_link = nil
                link_seconds = nil
                file_name = nil
              else
                file_name     = r.data_asset['filename']
                link_seconds  = 300
                file_link     = nil
              end
              f = r.folders ? r.folders.first : nil
              parent_pid = f && f.parent ? f.parent.pid : nil
              folder = f ? {pid: f.pid} : nil
              
              tr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if (f.scope == 'mine') && (r.user == @current_user)
            end
            t_arr << {pid: f.pid, name: f.name, resources: tr_arr}
          end
          sr_arr = []
          f.resources.where(scope: 'mine', user_id: @current_user.id).each do |r|
            parr = []
            projs = r.projects
            projs.each do |p|
              parr << {pid: p.pid, name: p.name, scope: p.scope}  
            end
            if r.data_asset.blank?
              file_link = nil
              link_seconds = nil
              file_name = nil
            else
              file_name     = r.data_asset['filename']
              link_seconds  = 300
              file_link     = nil
            end
            f = r.folders ? r.folders.first : nil
            parent_pid = f && f.parent ? f.parent.pid : nil
            folder = f ? {pid: f.pid} : nil
            
            sr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if (f.scope == 'mine') && (r.user == @current_user)
          end
          s_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: t_arr, resources: sr_arr}
        end
        fr_arr = []
        f.resources.where(scope: 'mine', user_id: @current_user.id).each do |r|
          parr = []
          projs = r.projects
          projs.each do |p|
            parr << {pid: p.pid, name: p.name, scope: p.scope}  
          end
          if r.data_asset.blank?
            file_link = nil
            link_seconds = nil
            file_name = nil
          else
            file_name     = r.data_asset['filename']
            link_seconds  = 300
            file_link     = nil
          end
          f = r.folders ? r.folders.first : nil
          parent_pid = f && f.parent ? f.parent.pid : nil
          folder = f ? {pid: f.pid} : nil
          
          fr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if (f.scope == 'mine') && (r.user == @current_user)
        end
        f_arr << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: s_arr, resources: fr_arr}
      end
      rr_arr = []
      f.resources.where(scope: 'mine', user_id: @current_user.id).each do |r|
        parr = []
        projs = r.projects
        projs.each do |p|
          parr << {pid: p.pid, name: p.name, scope: p.scope}  
        end
        if r.data_asset.blank?
          file_link = nil
          link_seconds = nil
          file_name = nil
        else
          file_name     = r.data_asset['filename']
          link_seconds  = 300
          file_link     = nil
        end
        f = r.folders ? r.folders.first : nil
        parent_pid = f && f.parent ? f.parent.pid : nil
        folder = f ? {pid: f.pid} : nil
        
        rr_arr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if (f.scope == 'mine') && (r.user == @current_user)
      end
      rpf << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: f_arr, resources: rr_arr}
    end

    shared_orphan_resources = []

    resources.each do |r|
      parr = []
      projs = r.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = nil
      end
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid} : nil
      shared_orphan_resources << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if r.orphan? && r.scope != 'mine'
    end

    private_orphan_resources = []

    private_resources = @current_user.resources.where(scope: 'mine')
    private_resources.each do |r|
      parr = []
      projs = r.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = nil
      end
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid} : nil
      private_orphan_resources << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, data_asset_name:file_name, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, updated_at: r.updated_at.strftime('%m/%d/%Y'), projects: parr} if r.orphan? && r.scope == 'mine'
    end

    if @current_user.org
      org = @current_user.org
      available_source_tags = all_source_tags(org)
    else
      available_source_tags = nil
    end

    srarr = SHARED_RESOURCES

    render json: {org_pid: @current_user.org.pid, shared_orphan_resources: shared_orphan_resources, private_orphan_resources: private_orphan_resources, available_source_tags: available_source_tags, shared_resources: srarr, shared_folders: rsf, private_folders: rpf}, status: :ok

  end

  def bulk_upload
    payload = bulk_resource_params[:payload].map { |payload_string| JSON.parse(payload_string) }
    payload.each_with_index do |resource, index|
      crawl_max_pages = resource['crawl_max_pages']
      resource['source_list'].downcase! if resource[:source_list]
      resource.delete("crawl_max_pages")
      r = Resource.new(resource.merge(user_id: @current_user.id, org_id: @current_user.org_id))
      org = @current_user.org

      if resource.has_key?('source_url') == true && valid_url?(resource['source_url'])
        r.source_url = resource_params['source_url']
      else
        r.data_asset = {
          filename: bulk_resource_params['files'][index].original_filename,
          content_type: bulk_resource_params['files'][index].content_type,
          bytes: File.size(bulk_resource_params['files'][index].tempfile),
          bucket_name: 'psci-bis-'+org.pid,
          sha: Digest::SHA256.hexdigest(File.read bulk_resource_params['files'][index].tempfile.path),
          utc_epoch: Time.now.utc.to_i
        }
      end

      if r.save
        r.update(state: 'active')
        r.reload

        if r.source_url.present?
          uri = URI.parse(r.source_url)
          name = uri.host+uri.path if uri
          if crawl_max_pages == 'single'
            max_pages = 1
            max_depth = 1
            @crawl = Crawl.create(resource_id: r.id, target_url: r.source_url, crawl_name: name, max_pages: max_pages, max_depth: max_depth, state: 'active')
            logger.debug vex_post_url(r)  if @crawl
          elsif crawl_max_pages == 'multi'
            max_pages = 25
            max_depth = 2
            @crawl = Crawl.create(resource_id: r.id, target_url: r.source_url, crawl_name: name, max_pages: max_pages, max_depth: max_depth, state: 'active')
            logger.debug vex_post_url(r)  if @crawl
          end
        elsif r.data_asset.present?
          h = r.data_asset
          h[:bucket_file_name] = 'resources/'+r.pid+'/data_asset/'+r.data_asset['filename']
          r.update(data_asset: h)
          GcsService.new(resource: r, tempfile: bulk_resource_params['files'][index].tempfile.path).upload
        end
      end
    end

    render json: { message: 'Resources created successfully' }
  end
  # GET /resources?query=my search string&page=3&per=10         # all params are optional
  # GET /resources?pdf_only=true
  def index
    if params[:pdf_only]
      # FIXME see Resource.pdf_only scope
      #  usage gives strange error "(Object doesn't support #inspect)"
      # This is why this hack is used instead
      resources = []
      query = Resource.where(org_id: @current_user.org.id)
      query = query.search_full_text(params[:q]) if !params[:q].blank?
      query.each do |r|
        resources << r if r.data_asset && r.data_asset['content_type'] == 'application/pdf'
      end
    else
      query = Resource
      query = query.where(org_id: @current_user.org.id)
      query = query.search_full_text(params[:q]) if !params[:q].blank?
      query = query.page(params[:page]).per(params[:per]) if !params[:page].blank? || !params[:per].blank?
      resources = query
    end

    rarr = []
    if @current_user.org
      org = @current_user.org
      available_source_tags = all_source_tags(org)
      # available_type_tags   = all_type_tags(org)
    else
      available_source_tags = nil
      # available_type_tags   = nil
    end
    resources.each do |r|
      
      parr = []
      projs = r.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = nil
      end
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
      rarr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, description: r.description, objective: r.objective, data_asset_name: file_name, file_link: file_link, link_seconds: link_seconds, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, created_at: r.created_at.strftime('%B %d, %Y'), updated_at: r.updated_at.strftime('%B %d, %Y'), projects: parr}  
    end
    srarr = SHARED_RESOURCES
    render json: {org_pid: org.pid, available_source_tags: available_source_tags, resources: rarr, shared_resources: srarr}
  end

  # POST /resources/filtered_results
  # {"source_tags": ["foo", "bar", "porsche"], "type_tags": ["ping pong"]}
  def filtered_results
    # return the same payload as GET /resources
    resources = Resource.where(org_id: @current_user.org.id)

    tagged_resources = []
    tagged_resources += resources.tagged_with(params[:source_tags], on: :source, any: true)
    # tagged_resources += resources.tagged_with(params[:type_tags], on: :type, any: true)
    tagged_resources = tagged_resources.uniq
    # .tagged_with("#{ActsAsTaggableOn::Tag.for_context(:source, :type)}")
    # logger.debug '****************************************'
    # logger.debug tagged_resources.inspect
    # logger.debug '****************************************'
    # render json: {foo: 'bar'} and return


    requested_source_tags = params[:source_tags]
    # requested_type_tags   = params[:type_tags]

    rarr = []
    if @current_user.org
      org = @current_user.org
      available_source_tags = all_source_tags(org)
      # available_type_tags   = all_type_tags(org)
    else
      available_source_tags = nil
      # available_type_tags   = nil
    end
    tagged_resources.each do |r|
      
      parr = []
      projs = r.projects
      projs.each do |p|
        parr << {pid: p.pid, name: p.name, scope: p.scope}  
      end
      
      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = nil # GcsService.new(resource: r, secondstolive: link_seconds).download_link
      end
  
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
      rarr << {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, description: r.description, objective: r.objective, data_asset_name: file_name, file_link: file_link, link_seconds: link_seconds, source_url: r.source_url, source_tags: r.source_list, scope: r.scope, state: r.state, created_at: r.created_at.strftime('%B %d, %Y'), updated_at: r.updated_at.strftime('%B %d, %Y'), projects: parr}  
    end
    
    render json: {org_pid: org.pid, requested_source_tags: requested_source_tags, available_source_tags: available_source_tags, resources: rarr}

  end
  
  # GET /resources/abc123
  def show
    r = Resource.find_by(pid: params[:id])
    if r
      return head 401 if @current_user.org != r.org
      projects = r.projects.where(org_id: @current_user.org.id)

      narr = []
      r_notes = r.notes ? r.notes : nil
      if r_notes
        r_notes.each do |n|
          created_at = n.created_at ? n.created_at.strftime('%m/%d/%Y') : nil
          narr << {user_pid: n.user.pid, pid: n.pid, text: n.text, created_at: created_at }
        end
      end
  
      parr = []
      projects = r.projects
      if projects
        projects.each do |p|
          created_at = p.created_at ? p.created_at.strftime('%m/%d/%Y') : nil
          parr << {project_pid: p.pid, name: p.name, created_at: created_at, deadline: p.deadline}  
        end
      end

      org = r.org ? r.org : nil

      available_source_tags = all_source_tags(org)  - r.source_list
      # available_type_tags   = all_type_tags(org)    - r.type_list

      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
        download = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = GcsService.new(resource: r, secondstolive: link_seconds).download_link
      end
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil

      crarr = []
      if r.crawl
        r.crawl.crawl_results.each do |cr|
          crarr << {page_title: cr.page_title, page_url: cr.url, extracted_text: cr.raw_text}
        end
        pages_crawled = r.crawl.crawl_results.where.not(raw_text: nil).count
        resource_crawl = {source_url: r.crawl.target_url, pages_crawled: pages_crawled, crawl_results: crarr}
      end

      payload = {org_pid: org.pid, user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, description: r.description, objective: r.objective, data_asset_name: file_name, file_link: file_link, link_seconds: link_seconds, source_url: r.source_url, source_tags: r.source_list, resource_crawl: resource_crawl, available_source_tags: available_source_tags, scope: r.scope, state: r.state, created_at: r.created_at.strftime('%B %d, %Y'), updated_at: r.updated_at.strftime('%B %d, %Y'), notes: narr, projects: parr}
      render json: payload
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # GET /resources/pid/resource_crawl
  def resource_crawl
    r = Resource.find_by(pid: params[:id])
    if r
      crarr = []
      if r.crawl
        r.crawl.crawl_results.each do |cr|
          crarr << {page_title: cr.page_title, page_url: cr.url, extracted_text: cr.raw_text}
        end
        pages_crawled = r.crawl.crawl_results.where.not(raw_text: nil).count
        resource_crawl = {crawl_pid: r.crawl.pid, source_url: r.crawl.target_url, pages_crawled: pages_crawled, crawl_results: crarr}
        render json: {resource_pid: r.pid, resource_crawl: resource_crawl}
      else
        render json: {error: 'Not found.'}, status: 404 and return
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /resources
  # {"crawl_max_pages": "single", "name": "a name", "description": "a description", "objective": "a objective", "source_list": ["foo", "bar"], "type_list": ["ping pong"]}
  def create
    crawl_max_pages = @quite_a_hack
    resource_params[:source_list].downcase! if resource_params[:source_list]
    # resource_params[:type_list].downcase!

    r = Resource.new(resource_params)
    u = @current_user
    org = u.org
    r.user_id                   = u.id
    r.org_id                    = org.id

    if resource_params.has_key?('source_url') == true && valid_url?(resource_params['source_url'])
      r.source_url = resource_params['source_url']
    elsif resource_params.has_key?('data_asset') == true && !resource_params['data_asset'].nil?
      r.data_asset = {
        filename:       resource_params['data_asset'].original_filename,
        content_type:   resource_params['data_asset'].content_type,
        bytes:          File.size(resource_params['data_asset'].tempfile),
        bucket_name:    'psci-bis-'+org.pid,
        sha:             Digest::SHA256.hexdigest(File.read resource_params['data_asset'].tempfile.path),
        utc_epoch:       Time.now.utc.to_i
      }
    else
      render json: {error: 'You must provide either an upload or a URL.'}, status: 400 and return
    end
      
    if r.save

      r.update(state: 'active')
      
      r = Resource.find r.id
      
      if r.source_url.present?

        uri = URI.parse(r.source_url)
        name = uri.host+uri.path if uri
        if crawl_max_pages == 'single'
          max_pages = 1
          max_depth = 1
          @crawl = Crawl.create(resource_id: r.id, target_url: r.source_url, crawl_name: name, max_pages: max_pages, max_depth: max_depth, state: 'active')
          # @crawl = Crawl.create(resource_id: r.id, target_url: 'https://johnknapp.com/k8s', crawl_name: 'johnknapp.com/k8s', max_pages: 25, max_depth: 2, state: 'active')
          logger.debug vex_post_url(r)  if @crawl
        elsif crawl_max_pages == 'multi'
          max_pages = 25
          max_depth = 2
          @crawl = Crawl.create(resource_id: r.id, target_url: r.source_url, crawl_name: name, max_pages: max_pages, max_depth: max_depth, state: 'active')
          # @crawl = Crawl.create(resource_id: r.id, target_url: 'https://johnknapp.com/k8s', crawl_name: 'johnknapp.com/k8s', max_pages: 25, max_depth: 2, state: 'active')
          logger.debug vex_post_url(r)  if @crawl
        end
        
      elsif r.data_asset.present?

        h = r.data_asset
        h[:bucket_file_name] = 'resources/'+r.pid+'/data_asset/'+r.data_asset['filename']
        r.update(data_asset: h)
        GcsService.new(resource: r, tempfile: resource_params['data_asset'].tempfile.path).upload
        
      end
      
      available_source_tags = all_source_tags(org)  - r.source_list

      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = GcsService.new(resource: r, secondstolive: link_seconds).download_link
      end
      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
      payload = {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, description: r.description, objective: r.objective, data_asset_name: file_name, file_link: file_link, link_seconds: link_seconds, source_url: r.source_url, source_tags: r.source_list, available_source_tags: available_source_tags, scope: r.scope, state: r.state}
      render json: payload, status: 201
    else
      render json: {error: 'There was an error.'}, status: 400
    end
  end

  # PUT /resources/abc123
  # {"name": "qwer", "description": "qwer", "objective": "qwer", "source_list": "foo, bar, ping pong", "type_list": ""}
  def update

    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    logger.debug resource_params.has_key?('data_asset') ? 'true' : 'false'
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    logger.debug resource_params[:data_asset].blank? ? 'true' : 'false'
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    logger.debug resource_params[:data_asset].class == ActionDispatch::Http::UploadedFile ? 'true' : 'false'
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    logger.debug request.params[:id]
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    
    r = Resource.find_by(pid: request.params[:id])
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    logger.debug r.inspect
    logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

    return head 401 unless @current_user.org == r.org
    if r && r.user_id == @current_user.id

      # data_asset gymnastics:
      #   resource_params[:data_asset] missing    retain    resource_params.has_key?('data_asset') == false
      #   resource_params[:data_asset] empty      remove    resource_params[:data_asset].nil?
      #   resource_params[:data_asset] present    replace   resource_params[:data_asset].class == ActionDispatch::Http::UploadedFile
      if resource_params.has_key?('data_asset') == true
        if resource_params[:data_asset].blank?# ? 'true' : 'false'
          result = 'the key is blank so we REMOVE'
          # but before we make data_asset nil, we remove the stored object
          GcsService.new(resource: r).delete
          r.update(data_asset: nil)
        elsif resource_params[:data_asset].class == ActionDispatch::Http::UploadedFile# ? 'true' : 'false'
          result = 'the key is preseent so we UPLOAD'
          sha = Digest::SHA256.hexdigest File.read resource_params['data_asset'].tempfile.path
          h = {}
          h[:filename]          = resource_params['data_asset'].original_filename
          h[:content_type]      = resource_params['data_asset'].content_type
          h[:bytes]             = File.size(resource_params['data_asset'].tempfile)
          h[:bucket_name]       = 'psci-bis-'+@current_user.org.pid
          h[:sha]               = sha
          h[:utc_epoch]         = Time.now.utc.to_i
          h[:bucket_file_name]  = 'resources/'+r.pid+'/data_asset/'+resource_params['data_asset'].original_filename
          r.update(data_asset: h)

          # foreground uploads
          GcsService.new(resource: r, tempfile: resource_params['data_asset'].tempfile.path).upload
          # background uploads
          # GcsJob.perform_async(r.id, 'upload', resource_params['data_asset'].tempfile.path)
        end
        # remove resource_params['data_asset']
        params.delete 'data_asset'
      # elsif 
      else
        result = 'the key is absent so we DO NOTHING'
      end

      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      logger.debug result
      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

      resource_params[:source_list].downcase!
      # resource_params[:type_list].downcase!

      r.update(resource_params)
      org = @current_user.org

      available_source_tags = all_source_tags(org)  - r.source_list
      # available_type_tags   = all_type_tags(org)    - r.type_list

      parr = []
      projects = r.projects
      if projects
        projects.each do |p|
          created_at = p.created_at ? p.created_at.strftime('%m/%d/%Y') : nil
          parr << {project_pid: p.pid, name: p.name, created_at: created_at, deadline: p.deadline}  
        end
      end

      if r.data_asset.blank?
        file_link = nil
        link_seconds = nil
        file_name = nil
      else
        file_name     = r.data_asset['filename']
        link_seconds  = 300
        file_link     = GcsService.new(resource: r, secondstolive: link_seconds).download_link
      end

      f = r.folders ? r.folders.first : nil
      parent_pid = f && f.parent ? f.parent.pid : nil
      folder = f ? {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type, parent_pid: parent_pid} : nil
      payload = {user_pid: r.user.pid, pid: r.pid, folder: folder, name: r.name, description: r.description, objective: r.objective, data_asset_name: file_name, file_link: file_link, link_seconds: link_seconds, source_url: r.source_url, source_tags: r.source_list, available_source_tags: available_source_tags, projects: parr, scope: r.scope, state: r.state}
      render json: payload, status: 200
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # DELETE /resources/abc123
  def destroy
    r = Resource.find_by(pid: params[:id])
    return head 401 unless @current_user.org == r.org
    if r && r.user_id == @current_user.id
      # detach from projects by deleting join records
      ProjectResource.where(resource_id: r.id).delete_all
      r.notes.delete_all
      GcsService.new(resource: r).remove_artifacts
      r.destroy
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /resources/pid/set_project_attachments
  # {"project_pids": ["abc","bcd","cde"]}
  def set_project_attachments
    r = Resource.find_by(pid: params[:id])
    if r && (r.org == @current_user.org)
      params[:project_pids].each do |pid|
        p = Project.find_by(pid: pid)
        if r.scope == p.scope
          r.projects << p unless r.projects.include? r
        else
          render json: {error: 'scope mismatch!'}, status: 400 and return
        end
      end
      action = "Attached resource pid #{r.pid} to project pids #{params[:project_pids]}"
      payload = {resource_pid: r.pid, project_pids: params[:project_pids], action: action}
      render json: payload and return
    else
      render json: {error: 'resource or org error'}, status: 400
    end
  end

  # POST /resources/pid/unfolder
  # {"source_folder_pid": "abc"}
  def unfolder
    r = Resource.find_by(pid: params[:id])
    if r
      source = Folder.find_by(pid: params[:source_folder_pid])
      FolderResource.where(folder_id: source.id, resource_id: r.id).delete_all
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /resources/pid/relocate_object
  # {"source_folder_pid": "abc", "destination_folder_pid": "def"}
  # null source is fine (orphan) destination is required!
  def relocate_object
    r = Resource.find_by(pid: params[:id])
    if r# && (r.org == @current_user.org)
      source = Folder.find_by(pid: params[:source_folder_pid])              # optional. if null, is orphan
      destination = Folder.find_by(pid: params[:destination_folder_pid])    # required!
      if destination && (destination.folder_type == 'resource') && (destination.scope == r.scope)
        FolderService.new(object: r, source_folder: source, destination_folder: destination).relocate_object
        children = []
        destination.children.each do |f|
          children << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
        end
        action = "relocated resource_pid #{r.pid} to folder_pid #{destination.pid}"
        payload = {resource_pid: r.pid, folder_pid: destination.pid, user_pid: r.user.pid, folder_name: destination.name, folder_scope: destination.scope, folder_type: destination.folder_type, children: children, action: action}
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
    r = Resource.find_by(pid: params[:id])
    if r
      source = s ? s : nil
      parent = p ? p : nil
      folder = FolderService.new(object: r, source_folder: source, destination_folder_name: params[:destination_folder_name], parent_folder: parent, user: @current_user).create_new_location
      parent_pid = parent ? parent.pid : nil
      action = "created folder_pid: #{folder.pid} to contain resource_pid #{r.pid}"
      payload = {resource_pid: r.pid, folder_pid: folder.pid, user_pid: folder.user.pid, folder_name: folder.name, folder_scope: folder.scope, parent_folder_pid: parent_pid, action: action}
      render json: payload, status: 201
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # GET /resources/tag_list
  def tag_list
    org = @current_user.org
    payload = {org_pid: org.pid, resources_tag_list: {all_source_tags: all_source_tags(org)}}
    render json: payload
  end

  # POST /resources/:id/add_note
  # {"text": "I am a very important note"}
  def add_note
    r = Resource.find_by(pid: params[:id])
    if r
      n = r.notes.create(user_id: @current_user.id, text: params[:text])
      if n
        created_at = n.created_at ? n.created_at.strftime('%m/%d/%Y') : nil
        payload = {pid: n.pid, text: n.text, created_at: created_at}
        render json: payload, status: 201
      else
        render json: {error: 'There was an error.'}, status: 400
      end
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /resources/:id/remove_note
  # {"note_pid": "abc123"}
  def remove_note
    r = Resource.find_by(pid: params[:id])
    n = Note.find_by(pid: params[:note_pid])
    if r && n && (r.notes.include? n)
      r.notes.delete n
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

    # I really hate doing stuff like this but hey, there's a deadline looming
    # TODO fix.
    def wtf_rails
      @quite_a_hack = params.to_unsafe_h[:crawl_max_pages]
    end

    # current tag list with counts
    def all_source_tags(org)
      ActsAsTaggableOn::Tagging.includes(:tag).where(tenant: org.id.to_s, taggable_type: 'Resource', context: 'source').map  { |tag| tag.tag.name }.uniq
      # ActsAsTaggableOn::Tagging.includes(:tag).where(tenant: org.id.to_s, taggable_type: 'Resource', context: 'source').map  { |tag| {name: tag.tag.name, count: tag.tag.count} }.uniq
    end
    
    # current tag list with counts
    def all_type_tags(org)
      # ActsAsTaggableOn::Tagging.includes(:tag).where(tenant: org.id.to_s, taggable_type: 'Resource', context: 'type').map    { |tag| tag.tag.name }.uniq
      # ActsAsTaggableOn::Tagging.includes(:tag).where(tenant: org.id.to_s, taggable_type: 'Resource', context: 'type').map    { |tag| {name: tag.tag.name, count: tag.tag.count} }.uniq
    end

    def resource_params
      params.delete 'controller'
      params.delete 'action'
      params.delete 'resource'
      params.delete 'id'
      params.delete 'crawl_max_pages'
      params.permit(:embedding, :name, :description, :objective, :source_url, :state, :data_asset, :source_list, :scope, :payload)
    end

    def bulk_resource_params
      params.permit(payload: [], files: [])
    end

    def vex_post_url(r)
      conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
      vex_url          = ENV.fetch('PSCI_VEX_BASE_URL')
      vex_key          = ENV.fetch('PSCI_VEX_API_KEY')
      conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
      conn.headers['Authorization'] = "Bearer #{vex_key}"

      max_pages = @crawl ? @crawl.max_pages : 1
      max_depth = @crawl ? @crawl.max_depth : 1
      payload = {
        resource_id: r.id,
        resource_pid: r.pid, 
        resource_name: r.name, 
        target_url: r.source_url,
        crawl_max_pages: max_pages,
        crawl_max_depth: max_depth,
        crawl_id: @crawl.id,
        model_code: 'ad',
        qdrant_collection: "psci-bis-#{r.org.pid}-ad"
      }

      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      logger.debug payload
      res = conn.post(vex_url + '/url',payload.to_json)
      body = JSON.parse(res.body) if res 
      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      logger.debug "This is body:"
      logger.debug body
      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
    end

end
# resource constants
#   bucket_name
#   pid
#   name
#   objective
#   
# resource variants
#   bytes
#   filename
#   content_type
#   sha
#   utc_epoch
# 