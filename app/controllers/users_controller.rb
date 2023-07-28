# frozen_string_literal: true

class UsersController < ApplicationController
  include Authentication

  before_action :require_api_key, except: [:verify_email]
  before_action :require_sign_in, except: [:verify_email]

  # GET /users/:pid/resend_verification_email
  def resend_verification_email
    user = User.find_by(pid: params[:user_id])
    if user
      if user.confirmation_token && user.email_verified == false
        UserMailer.with(user: user).verify_email.deliver_now
        # UserMailer.with(user: @user).verify_email.deliver_later
        head 204
      else
        render json: {error: 'already verified'}, status: 410
      end
    else
      render json: {error: 'not found'}, status: :not_found
    end
  end

  # PUT /users/verify_email
  # {"confirmation_token": "abc123"}
  def verify_email
    user = User.find_by(confirmation_token: user_params[:confirmation_token])
    if user && user.confirmation_token
      user.update(confirmation_token: nil, email_verified: true)
      head 200
    else
      render json: {error: 'not found'}, status: :not_found
    end
  end
  
  # GET /users/:pid
  def show
    user = User.find_by(pid: params[:id])
    if user
      user_payload(user)
      render json: @payload.to_json
    else
      render json: {error: 'not found'}, status: :not_found
    end
  end

  # POST /users/pid/activate_in_group
  # (group_pid: ’abc'}
  def activate_in_group
    g = Group.find_by(pid: params[:group_pid])
    u = User.find_by(pid: params[:id])
    if u && g && g.org == @current_user.org
      u.activate_in_group(g)
      gmarr = []
      members = g.members
      g.members.each do |gm|
        active = g == gm.group ? true : false
        gmarr << {user_pid: gm.pid, user_name: gm.name, active: active}
      end
      render json: {group_pid: g.pid, group_members: gmarr}
    else
      render json: {error: 'user or group not found'}, status: 404
    end
end
  
  # PUT /users/:pid
  # {"fname":"Ima", "lname":"User", "email":"user1@example.com"}
  def update
    user = User.find_by(pid: params[:id])
    if user && user == @current_user
      if params[:email] && (user.email != params[:email])
        # email change requires reverification
        user.update(confirmation_token: Generator.confirmation_token(user), email_verified: false)
        UserMailer.with(user: user).verify_email.deliver_now
      end
      if user.update(user_params)
        user_payload(user)
        render json: @payload.to_json
      else
        render json: {error: "there was an error"}, status: 400
      end
    else
      render json: {error: 'not found'}, status: :not_found
    end
  end
  
  private

    def user_payload(user)
      org = {org_pid: user.org.pid, org_name: user.org.name, org_type: user.org.org_type}
      garr = []
      user.group_memberships.each do |g|
        active = g == user.group ? true : false
        garr << {group_pid: g.pid, group_name: g.name, active: active}
      end
      perms = user.permissions ? user.permissions : nil
      profile = { fname: user.fname, lname: user.lname, org: org, group_memberships: garr, joined_on: user.created_at.strftime('%B %d, %Y') }
      @payload = { pid: user.pid, email: user.email, email_verified: user.email_verified, permissions: perms, profile: profile }
    end

    def user_params
      params.require(:user).permit(:fname, :lname, :email, :confirmation_token, :user_id)
    end

end