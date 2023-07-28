# frozen_string_literal: true

class License < ApplicationRecord
  include Pid
  belongs_to :org
  has_many :allocations, dependent: :destroy
  has_many :users, through: :allocations

  def allocated_quantity
    self.allocations.count  
  end

  def allocations_available
    self.quantity - self.allocated_quantity
  end

  def licensees
    self.users
  end

end
