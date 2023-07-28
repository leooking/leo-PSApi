# frozen_string_literal: true

class UserNotificationsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET users_notifications/
  def index
    user_notifications = UserNotification.where(user: @current_user)
    if user_notifications
      aarr = []
      user_notifications.each do |n|
        aarr << {message: n.message, message_type: n.message_type, read: n.read, pid: n.pid}
      end
      render json: aarr
    else
      render json: {error: 'not found'}, status: :not_found
    end
  end

  # DELETE /user_notifications/abc123
  def destroy
    n = UserNotification.find_by(pid: params[:id])
    if n && n.user == @current_user
      n.destroy
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  # POST user_notifications/abc123/mark_as_read
  def mark_as_read
    n = UserNotification.find_by(pid: params[:id])
    if n && n.user == @current_user
      n.read = true
      n.save
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

  def user_notifications_params
    params.require(:user_notifications).permit(:notification_id)
  end

end