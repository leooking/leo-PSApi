# frozen_string_literal: true

class Role < ApplicationRecord
  include Pid
  
  has_many :permission_roles
  has_many :permissions, through: :permission_roles
  has_many :role_users
  has_many :users, through: :role_users
end
