# frozen_string_literal: true

class SessionController < ApplicationController
  include Authentication

  before_action :require_api_key, except: [:email, :reset_request, :password_reset]
  before_action :require_sign_in, except: [:valid_email, :email, :password, :reset_request, :password_reset, :verify_otp]

  # GET /session/auth
  # a simple header check
  def auth
    head :ok
  end

  def valid_email
    e = params[:email]
    u = User.find_by(email: e)
    if u
      head :ok
    else
      head 401
    end
  end

  # POST /session/email
  # {"email": "foo@bar.com"}
  def email
    user = User.find_by(email: session_params[:email])
    if user
      auth_type = 'sign-in'
    else
      auth_type = 'sign-up'
      render json: {error: 'You must apply for membership'}, status: 401 and return
      # user = User.create(session_params)
    end

    if user.present?
      auth_token = Base64.urlsafe_encode64(user.email) + '.' + Time.now.utc.to_i.to_s
      user.update_attribute(:auth_token, auth_token) # update_attribute to avoid username validation
      h = {pid: user.pid, email: user.email, auth_type: auth_type, auth_token: auth_token, api_key: ENV['API_KEY'], mfa_enabled: user.mfa_enabled}
      # logger.debug('JKJKJK Email payload')
      # logger.debug h
      # logger.debug('JKJKJK Email payload')
      render json: h.to_json
    elsif user.present?
      render json: {error: 'You do not yet have access. We will notify you via email when access is available'}, status: 425
    else
      render json: {error: 'Your sign-in attempt could not be processed.'}, status: 400
    end
  end

  # POST /session/password
  # {"password": "s3cret", "auth_token": "Zm9vQGJhci5jb20.1604700228"}
  def password
    time_int = session_params['auth_token'].split('.').last.to_i
    if Time.at(time_int).utc < Time.now.utc - 180
      render json: {error: 'You only have 3 minutes to enter your password'}, status: 403 and return
    end
    user = User.find_by(auth_token: session_params['auth_token'])
    if user
      # make sure every non-verified emails have a confirmation_token
      user.update_attribute(:confirmation_token, Generator.confirmation_token(user)) if user.email_verified == false
      # Returning user logic - confirm their password
      if user.password_hash
        unless Argon2::Password.verify_password(session_params[:password], user.password_hash, ENV['ARGON_KEY'])
          render json: { error: 'There was an error.' }, status: 400 and return
        end
      else
        # New user logic - create their password and prepare to confirm their email
        argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])
        user.update_attribute(:password_hash, argon.create(session_params[:password]))
        user.update_attribute(:confirmation_token, Generator.confirmation_token(user)) unless user.confirmation_token
        UserMailer.with(user: user).verify_email.deliver_now
      end
    else
      render json: {error: 'There was an error.'}, status: 400 and return
    end

    if user.mfa_enabled?
      user.generate_otp_secret
      totp = user.get_totp
      UserMailer.with(user: user, otp:totp.password).email_security_code.deliver_now
      h = {pid: user.pid, email: user.email, email_verified: user.email_verified, mfa_enabled: user.mfa_enabled}
      render json: h.to_json
    else
      response = auth_response(user)
      render json: response.to_json
    end

  end

  # POST /session/verify_otp
  # {"otp": "123456", "auth_token": "Zm9vQGJhci5jb20.1604700228"}
  def verify_otp
    user = User.find_by(auth_token: session_params['auth_token'])
    return render json: {error: 'There was an error.'}, status: 400 unless user.present?

    if user.verify_otp(session_params['otp'].to_s)
      response = auth_response(user)
      render json: response.to_json
    else
      render json: {error: 'Invalid OTP'}, status: 400 and return
    end
  end

  # POST /session/reset_request
  # {email: 'foo@bar.com'}
  def reset_request
    user = User.find_by(email: session_params[:email])
    unless user
      render json: {error: 'There was an error'}, status: 400 and return
    else
      password_reset_token = Generator.password_reset_token(user)
      user.update_attribute(:password_reset_token, password_reset_token)
      UserMailer.with(user: user).password_reset_instructions.deliver_now
      # UserMailer.with(user: user).reset_instructions.deliver_later
      render json: {message: 'password reset instructions sent by email'}
    end
  end

  # POST /session/password_reset
  # { "password": "password", "token": "123ljkpic.1660425453" }
  def password_reset
    user = User.find_by(password_reset_token: session_params[:token])
    unless user
      render json: {error: 'user not found'}, status: 403 and return
    end
    token_seconds = session_params['token'].split('.').last.to_i
    if Time.at(token_seconds).utc < Time.now.utc - 86400 # a day in seconds
      render json: {error: 'expired password_token'}, status: 401 and return
    else
      argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])
      user.update_attribute(:password_hash, argon.create(session_params[:password]))
      user.update_attribute(:password_reset_token, nil)
      render json: {message: 'your password has been reset'}
    end
  end

  # POST /session/token_refresh?grant_type=refresh_token&refresh_token=abc123xyz890
  # This requires valid actok as auth header and the api-key header
  def token_refresh
    retok = params[:refresh_token]
    email = TokenService.new(token: retok).valid_token_email?

    if email && email == @current_user.email
      result = TokenService.new(token: retok, user: @current_user).refresh_access_token
    else
      render json: {error: 'Bad request'}, status: 403 and return
    end

    if result
      h = {actok: result, issued_at: Time.now.utc}
      render json: h.to_json
    else
      render json: {error: 'Bad request'}, status: 403 and return
    end
  end

  private

    def auth_response (user)

      user.update_attribute(:auth_token, nil)
      user.update_attribute(:last_login, Time.now)
      user.update_attribute(:login_count, user.login_count+1)

      # TODO don't send a new retok (token_pair[1]) unless the current retok is expired
      #   chat with JK about this

      token_pair  = TokenService.new(user: user).create_token_pair
      unless token_pair
        render json: {error: 'There was an error'}, status: 422 and return
      end
      org = {org_pid: user.org.pid, org_name: user.org.name, org_type: user.org.org_type}
      garr = []
      user.group_memberships.each do |g|
        active = g == user.group ? true : false
        garr << {group_pid: g.pid, group_name: g.name, active: active}
      end
      ig = AssetGenerator.where(home_showcase: true).first
      generator_type = ig ? ig.generator_type : nil
      generator_pid  = ig ? ig.pid : nil
      n = Notification.where(state: 'active').first
      if n
        notification = {display_text: n.display_text, modal: n.modal, top_bar: n.top_bar, top_bar_color: n.top_bar_color}
      else
        notification = nil
      end
      r = Asset.includes(:asset_interactions).where(user_id: user.id).order('asset_interactions.created_at DESC')
      recent_assets = []
      if r
        r.each do |a|
          generator_type = a.asset_generator ? a.asset_generator.generator_type : nil
          generator_name = a.asset_generator ? a.asset_generator.name : nil
          latest_interaction = a.asset_interactions.order(created_at: :desc).pluck(:created_at).first
          last_updated = latest_interaction ? latest_interaction.strftime('%m/%d/%Y') : a.updated_at.strftime('%m/%d/%Y')
          recent_assets << {pid:a.pid, name:a.name, interactions: a.asset_interactions.count, generator_type: generator_type, generator_name: generator_name, last_updated: last_updated}
        end
      end
      perms = user.permissions ? user.permissions : nil
      profile = { fname: user.fname, lname: user.lname, org: org, group_memberships: garr, joined_on: user.created_at.strftime('%B %d, %Y') }
      h = { notification: notification, recent_assets: recent_assets, permissions: perms, pid: user.pid, actok: token_pair[0], retok: token_pair[1], issued_at: Time.now.utc, email: user.email, email_verified: user.email_verified, dashboard_home: user.dashboard_home, generator_type: generator_type, generator_pid: generator_pid, profile: profile }

      return h

    end

    def session_params
      params.require(:session).permit(:email, :password, :auth_token, :refresh_token, :token, :otp) # shorthand param naming
    end

end
