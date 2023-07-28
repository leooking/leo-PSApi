class Auth0Controller < ApplicationController
  def token_verification
    begin
      id_token = auth0_params['id_token']
      jwks_url = ENV['AUTH0_JWKS_URL']

      # Fetch the JWKS (JSON Web Key Set) from the Auth0 to decode the token
      jwks_raw = Net::HTTP.get(URI(jwks_url))
      jwks_keys = Array(JSON.parse(jwks_raw)['keys'])

      # Decode the ID token using the JWKS keys for signature verification
      decoded_token, _header = JWT.decode(
        id_token,
        nil,
        true,
        algorithm: 'RS256',
        jwks: jwks_keys
      )

      user_email = decoded_token['email']
      user = User.find_by(email: user_email)
      return render json: {error: "User is not registered with email: #{user_email}. You must apply for membership"}, status: 401 unless user.present?

      # Update user attributes is user exists
      user.update_attribute(:confirmation_token, Generator.confirmation_token(user)) if user.email_verified == false
      user.update_attribute(:last_login, Time.now)
      user.update_attribute(:login_count, user.login_count+1)


      token_pair  = TokenService.new(user: user).create_token_pair
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
      perms = user.permissions ? user.permissions : nil
      profile = { fname: user.fname, lname: user.lname, org: org, group_memberships: garr, joined_on: user.created_at.strftime('%B %d, %Y') }

      # Group response data
      h = { notification: notification, permissions: perms, pid: user.pid, actok: token_pair[0], retok: token_pair[1], issued_at: Time.now.utc, email: user.email, email_verified: user.email_verified, dashboard_home: user.dashboard_home, generator_type: generator_type, generator_pid: generator_pid, profile: profile, api_key: ENV['API_KEY'] }

      render json: h.to_json
    rescue StandardError => _e
      render json: { error: "Auth0 token is expired or invalid" }, status: 401
    end
  end

  private

    def auth0_params
      params.require(:auth0).permit(:access_token, :id_token)
    end

end
