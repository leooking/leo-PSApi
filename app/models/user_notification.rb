class UserNotification < ApplicationRecord
  include Pid
  belongs_to :user
end
