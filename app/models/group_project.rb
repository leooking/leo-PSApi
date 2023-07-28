class GroupProject < ApplicationRecord
  belongs_to :group
  belongs_to :project
end
