# frozen_string_literal: true

class UserNotificationsService

  def initialize(args)
    @logger = Logger.new($stdout)
    @user = args[:user]
  end

  def send_user_notification(text, type)
    UserNotification.create(user: @user, message: text, message_type: type)
  end

  private

end
