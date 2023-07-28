# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    rescue_from ActiveRecord::RecordNotFound do |resource|
      render json: { error: 'Record not found' }, status: :not_found
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message.split(':').map(&:strip).first }, status: :unprocessable_entity
    end
  end
end
