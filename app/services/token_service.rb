# frozen_string_literal: true

class TokenService
    
  def initialize(args)
    @hmac_secret        = 'b20608c9omg!m24t37'
    @algo               = 'HS256'                 # CAREFUL! this is being used (in base64) as conditional on testing auth header
    @seconds_to_live    = 1200                    # 20 minutes
    @leeway_seconds     = 60                      #  1 minute
    @refresh_seconds    = 3888000                 # 45 days

    @user               = args[:user]
    @token              = args[:token]
  end

  def create_token_pair
    generate_access_token
    generate_refresh_token
    [@access_token,@refresh_token]
  end

  def refresh_access_token
    generate_access_token
  end
  
  def valid_token_email?
    valid_token_email
  end

  private

    def generate_access_token
      claims = {
        exp:          Time.now.utc.to_i + @seconds_to_live,
        iat:          Time.now.utc.to_i,
        email:        @user.email
      }
      @access_token = JWT.encode claims, @hmac_secret, @algo
    end  
    
    def generate_refresh_token
      claims = {
        exp:          Time.now.utc.to_i + @refresh_seconds,
        iat:          Time.now.utc.to_i,
        email:        @user.email
      }
      @refresh_token = JWT.encode claims, @hmac_secret, @algo
      @user.update(refresh_token: @refresh_token)
    end

    def valid_token_email
      begin
        decoded_token = JWT.decode @token, @hmac_secret, true, { 
          exp_leeway:     @leeway_seconds, 
          algorithm:      @algo 
        }
      rescue JWT::DecodeError
        return nil
      rescue JWT::InvalidIatError
        return nil
      rescue JWT::ExpiredSignature
        return nil
      else
        @email = decoded_token[0]['email']
      end
    end

  end
