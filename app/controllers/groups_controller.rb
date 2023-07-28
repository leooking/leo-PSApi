# frozen_string_literal: true

class GroupsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /groups
  def index
    o = @current_user.org
    groups = Group.where(org_id: o.id)
    garr = []
    groups.each do |g|
      creator = g.creator ? g.creator.pid : nil
      marr = []
      g.members.each do |u|
        active = g == u.group ? true : false
        marr << {user_pid: u.pid, user_name: u.name, active: active} if u
      end
      garr << {org_pid: g.org.pid, user_pid: creator, pid: g.pid, name: g.name, members: marr}
    end
    render json: {groups: garr}
  end

  # GET /groups/pid
  def show
    g = Group.find_by(pid: params[:id])
    if g
      gmarr = []
      members = g.members
      g.members.each do |gm|
        active = g == gm.group ? true : false
        gmarr << {user_pid: gm.pid, user_name: gm.name, user_email: gm.email, active: active}
      end
      render json: {org_pid: g.org.pid, org_name: g.org.name, org_type: g.org.org_type, group_pid: g.pid, group_name: g.name, group_members: gmarr}
    else
      render json: {error: 'user or group not found'}, status: 404
    end
  end

  # POST/groups/pid/bulk_add
  # {"member_pids": ["19f","8etn","r5j"]}
  def bulk_add
    g = Group.find_by(pid: params[:id])
    pids = params[:member_pids]
    uarr = []
    pids.each do |p|
      u = User.find_by(pid: p)
      uarr << u if u
    end
    uarr.each do |u|
      u.activate_in_group(g) if (u && u.org == @current_user.org)
    end
    gmarr = []
    g.members.each do |u|
      active = g == u.group ? true : false
      gmarr << {user_pid: u.pid, user_name: u.name, active: active} if u
    end
    render json: {group_pid: g.pid, group_members: gmarr}
  end

  # POST /groups/pid/add_member
  # {user_pid: 'abc123'}
  def add_member
    g = Group.find_by(pid: params[:id])
    u = User.find_by(pid: params[:user_pid])
    if g && g.org == @current_user.org
      if g.org == u.org
        gmarr = []
        members = g.members
        g.members << u
        g.members.each do |gm|
          active = g == gm.group ? true : false
          gmarr << {user_pid: gm.pid, user_name: gm.name, active: active}
        end
        render json: {group_pid: g.pid, group_members: gmarr}
      else
        render json: {error: 'user must be in the same group'}, status: 400 and return
      end
    else
      render json: {error: 'group not found'}, status: 404
    end
  end
  # POST /groups/pid/remove_member
  # {user_pid: 'abc123'}
  def remove_member
    g = Group.find_by(pid: params[:id])
    u = User.find_by(pid: params[:user_pid])
    if g && g.org == @current_user.org
      if g.org == u.org
        gmarr = []
        g.members.delete u
        members = g.members
        g.members.each do |gm|
          gmarr = {user_pid: gm.pid, user_name: gm.name}
        end
        render json: {group_pid: g.pid, group_members: gmarr}
      else
        render json: {error: 'user must be in the same group'}, status: 400 and return
      end
    else
      render json: {error: 'group not found'}, status: 404
    end
  end

  # POST /groups
  # {name: 'pizza'}
  def create
    u = @current_user
    g = Group.create(group_params)
    if g
      g.update(org_id: u.org.id, user_id: u.id)
      render json: {org_pid: u.org.pid, user_pid: u.pid, pid: g.pid, name: g.name}
    else
      render json: {error: 'group could not be created'}, status: 400
    end
  end
  
  # PUT /groups/pid
  # {name: 'cheese pizza'}
  def update
    g = Group.find_by(pid: params[:id])
    u = @current_user
    if g && g.org == u.org
      g.update(group_params)
      render json: {org_pid: g.org.pid, user_pid: u.pid, pid: g.pid, name: g.name}
    else
      render json: {error: 'group not found'}, status: 404
    end
  end
  
  # DELETE /groups/pid
  def destroy
    g = Group.find_by(pid: params[:id])
    if g && g.creator == @current_user
      if g.members.present?
        render json: {error: 'Group contains members, remove them before deleting!'}, status: 403
      else
        g.destroy
        render json: {message: 'Group successfully deleted'}
      end
    else
      render json: {error: 'Group not found'}, status: 404
    end
  end

  private

    def group_params
      params.require(:group).permit(:name)
    end

end
