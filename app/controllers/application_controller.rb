# frozen_string_literal: true

# Thanks activeadmin, you bother me
# class ApplicationController < ActionController::API
class ApplicationController < ActionController::Base

  before_action :set_current_user
  
  # API csrf strategy
  skip_before_action :verify_authenticity_token

  # See https://medium.com/@apneadiving/why-i-do-not-use-strong-parameters-in-rails-e3bd07fcda1d
  # def params
  #   request.parameters
  # end

  private

    def set_current_user
      if request.headers["Authorization"]
        actok = request.headers["Authorization"].split(' ')[1]
        if actok
          access_result = TokenService.new(token: actok).valid_token_email?
          @current_user = User.find_by(email: access_result)
        else
          nil
        end
      else
        nil
      end
    end

end
