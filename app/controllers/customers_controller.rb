# frozen_string_literal: true

class CustomersController < ApplicationController

  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /customers/dashboard
  def dashboard
    org = @current_user.org
    render json: { error: 'Something went wrong' }, status: 400 and return unless org

    groups = []
    users = []
    licenses_array = []
    nb_resources = org.resources.length
    projects = Project.where(org_id: org.id).all
    nb_projects = projects.count
    nb_assets = 0

    projects.each do |project|
      nb_assets += project.assets.length
    end

    licenses_summary = @current_user.org.licenses_summary ? @current_user.org.licenses_summary : nil

    @current_user.org.users&.each do |user|
      garr = []
      user.group_memberships.each do |g|
        active = user.group == g ? true : false
        garr << {group_pid: g.pid, group_name: g.name, active: active}
      end
      users << {
        pid: user.pid, name: user.name, email: user.email, group_memberships: garr, joined_on: user.created_at.strftime('%m/%d/%Y')
      }
    end

    @current_user.org.groups&.each do |group|
      member_arr = []
      available_arr = []
      group_members = group.members
      active_members = group.active_members

      active_members.each do |u|
        member_arr << {user_pid: u.pid, user_name: u.name}
      end
      group_members.each do |u|
        available_arr << {user_pid: u.pid, user_name: u.name} unless active_members.include? u
      end

      groups << {
        pid: group.pid, name: group.name, current_members: member_arr, potential_members: available_arr, created_at: group.created_at.strftime('%m/%d/%Y')
      }
    end

    @current_user.org.licenses&.each do |license|
      licenses_array << {
        pid: license.pid, name: license.name, quantity: license.quantity, allocated: license.allocated_quantity,
        available: license.allocations_available, expire: license.expires_on.strftime('%m/%d/%Y')
      }
    end

    render json: {
      summary: { resources: nb_resources, projects: nb_projects, assets: nb_assets },
      license: { licenses: licenses_array, summary: licenses_summary },
      groups: groups,
      users: users
    }
  end

  # GET customers/users
  def users
    uarr = []
    o = @current_user.org
    users = o.users.order(:lname)
    users.each do |u|
      garr = []
      u.group_memberships.each do |g|
        garr << { name: g.name, pid: g.pid, members_count: g.members.count}
      end
      uarr << {pid: u.pid, name: u.name, email: u.email, group_memberships: garr}
    end
    render json: { users: uarr }
  end

  # GET customers/groups
  def groups
    groups = []
    Group.where(org: @current_user.org).all&.each do |group|
      groups << { name: group.name, pid: group.pid, members_count: group.members.count}
    end
    render json: { groups: groups }
  end

  # POST customers/group_management
  # {"group_pid": "abcsj", "users_add": ["abc","def","ghi"], "users_remove": ["123","234"]}
  # all users are always active in exactly one group
  def group_management
    group_pid = params.to_unsafe_h[:group_pid]
    users_add = params.to_unsafe_h[:users_add]
    users_remove = params.to_unsafe_h[:users_remove]
    g = Group.find_by(pid: group_pid)
    default = Group.find_by(name: 'default')
    if g
      add_arr = []
      remove_arr = []
      to_add = users_add
      to_remove = users_remove
      if to_add
        to_add.each do |pid|
          add_arr << User.find_by(pid: pid)
        end
        add_arr.compact.each do |u|
          u.activate_in_group(g)
        end
      end
      if to_remove
        to_remove.each do |pid|
          remove_arr << User.find_by(pid: pid)
        end
        remove_arr.compact.each do |u|
          u.activate_in_group(default)
        end
      end
      render json: {message: 'group memberships updated'}, status: 200
    else
      render json: {error: 'invalid group identifier'}, status: 404
    end

  end

  # POST customers/add_user
  # {"fname": "foo", "lname": "bar", "email": "foo@bar.com","group": "pid"}
  def add_user
    group_pid = params.require(:group)
    fname = params.require(:fname)
    lname = params.require(:lname)
    email = params.require(:email)
    group = Group.find_by(pid: group_pid)

    render json: { error: "Group doesn't exist" }, status: 404 and return unless group

    render json: { error: 'Email already exists' }, status: 400 and return if User.find_by_email(email)

    begin
      # NOTE: deprecating user.group_id to support multiple group membership
      user = User.create(fname: fname, lname: lname, email: email, org_id: @current_user.org.id)
      # user = User.create(fname: fname, lname: lname, email: email, group_id: group.id, org_id: @current_user.org.id)
      # Activating a user puts them into a group and sets active: true on GroupUser record
      user.activate_in_group(group)
      render json: { message: 'Successfully added', user: {
        fname: user.fname, lname: user.lname, org: @current_user.org.name, group: group.name, joined_on: user.created_at.strftime('%B %d, %Y')
      } }
    rescue StandardError
      render json: { message: 'Failed to add a new user' }, status: 400
    end
  end

  # PUT /customers/update_user
  # {"user_pid": "abc123", fname": "foo", "lname": "bar", "email": "foo@bar.com","group_pid": "123abc"}`
  def update_user
    u = User.find_by(pid: params[:user_pid])
    g = Group.find_by(pid: params[:group_pid])
    if u && g
      u.fname     = params[:fname] if params[:fname]
      u.lname     = params[:lname] if params[:lname]
      u.email     = params[:email] if params[:email]
      u.activate_in_group(g)

      UserMailer.with(user: u).verify_email.deliver_now if params[:email]

      
    else
      render json: {error: "User or group doesn't exist!"}
    end
  end

  def add_bulk_user
    csv_file = params[:csv]

    render json: { error: 'CSV file required.' }, status: 404 and return unless csv_file

    begin
      total_cnt = CsvService
                    .new(tempfile: csv_file).provision_customer_users(@current_user.org.pid, @current_user.group.pid)
      render json: { message: 'Successfully added users', total_cnt: total_cnt }
    rescue StandardError
      render json: { message: 'Failed to add users' }, status: 400 and return
    end
  end

  private

    def customer_params
      params.permit(:group_pid, :users_add, :users_remove, :fname, :lname, :email)
    end

end
