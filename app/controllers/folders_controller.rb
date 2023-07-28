# frozen_string_literal: true

class FoldersController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /folders
  def index
    folders = Folder.where(org_id: @current_user.org.id)
    if folders
      farr = []
      folders.each do |f|
        parent_pid = f.parent ? f.parent.pid : nil
        children = f.children
        kids = []
        children.each do |c|
          parent_pid = c.parent ? c.parent.pid : nil
          kids << {pid: c.pid, parent_pid: parent_pid, name: c.name, scope: c.scope, folder_type: c.folder_type}
        end
        farr << {pid: f.pid, user_pid: f.user.pid, parent_pid: parent_pid, name: f.name, scope: f.scope, folder_type: f.folder_type, children: kids}
      end
      render json: {org_pid: @current_user.org.pid, folders: farr}
    else
      render json: {error: 'there was an error'}, status: 400
    end
  end

  # POST /folders
  # create empty scoped folder of a type
  # if child, the type and scope must match the parent!
  # {name: 'a folder', scope: 'group', parent_pid: 'abc', folder_type: 'asset'}
  def create
    f = Folder.new(folder_params)
    f.org_id = @current_user.org.id
    f.user_id = @current_user.id
    p = Folder.find_by(pid: params[:parent_pid]) if params[:parent_pid]
    if p
      unless (f.folder_type == p.folder_type) && (f.scope == p.scope)
        render json: {error: 'parent_folder scope or folder_type mismatch!'}, status: 400 and return
      end
    end
    if f.save
      parent_pid = p ? p.pid : nil
      payload = {pid: f.pid, user_pid: f.user.pid, parent_pid: parent_pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
      render json: payload, status: :ok and return
    else
      render json: {error: 'there was an error'}, status: 400 and return
    end
  end
  
  # PUT /folders/pid
  # if child, the type and scope must match the parent!
  # {name: 'a folder', scope: 'group', parent_pid: 'abc', folder_type: 'asset'}
  def update
    f = Folder.find_by(pid: params[:id])
    p = Folder.find_by(pid: params[:parent_pid])
    if f
      if p 
        unless (f.folder_type == p.folder_type) && (f.scope == p.scope)
          render json: {error: 'parent_folder scope or folder_type mismatch!'}, status: 400 and return
        end
      end
      f.update(name: params[:name])
      f.update(parent_id: p.id) if p
      parent_pid = p ? p.pid : nil
      payload = {pid: f.pid, user_pid: f.user.pid, parent_pid: parent_pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
      render json: payload, status: :ok
    else
      render json: {error: 'not found'}, status: 404
    end
  end
  
  # POST /folders/pid/unfolder
  # {"source_folder_pid": "abc"} # optional
  def unfolder
    f = Folder.find_by(pid: params[:id])
    if f
      f.update(parent_id: nil)
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST /folders/pid/relocate_folder
  # {"source_folder_pid": "abc", "destination_folder_pid": "def"}
  # all objects within this folder are moved with it
  def relocate_folder
    source = Folder.find_by(pid: params[:source_folder_pid])            # optional. if null, object is orphan
    destination = Folder.find_by(pid: params[:destination_folder_pid])  # required!
    folder = Folder.find_by(pid: params[:id])
    if folder && (folder.user == @current_user) && (destination.folder_type == folder.folder_type) && (destination.scope == folder.scope)
      FolderService.new(object: folder, source_folder: source, destination_folder: destination).relocate_object
      children = []
      destination.children.each do |f|
        children << {pid: f.pid, user_pid: f.user.pid, name: f.name, scope: f.scope, folder_type: f.folder_type}
      end
      action = "relocated folder_pid #{folder.pid} to destination_folder_pid #{destination.pid}"
      payload = {object_folder_pid: folder.pid, destination_folder_pid: destination.pid, user_pid: folder.user.pid, destination_folder_name: destination.name, destination_folder_scope: destination.scope, destination_folder_type: destination.folder_type, destination_folder_children: children, action: action}
      render json: payload
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # DELETE /folders/pid
  def destroy
    f = Folder.find_by(pid: params[:id])
    if f
      unless f.empty?
        render json: {error: 'cannot delete a non-empty folder!'}, status: 400 and return
      end
      # make any children root level
      Folder.where(parent_id: f.id).update_all(parent_id: nil)
      f.delete
      head :ok
    else
      render json: {error: 'not found'}, status: 404
    end
  end

  private

  def folder_params
    params.delete(:folder)
    params.delete(:parent_pid)
    params.permit(:id, :name, :scope, :folder_type)
  end

end