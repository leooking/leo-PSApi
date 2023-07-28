class StateAgency < ApplicationRecord
  include Pid
  belongs_to :state
end
