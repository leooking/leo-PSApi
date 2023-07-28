# frozen_string_literal: true

module Authentication
  def require_api_key
    return if request.headers['x-api-key'] == ENV['API_KEY']

    render json: { error: 'sorry, no can do' }, status: :unauthorized
  end

  def require_sign_in
    render json: { error: 'you must be signed-in to access that' }, status: :unauthorized unless @current_user
  end

end
