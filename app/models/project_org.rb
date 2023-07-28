class ProjectOrg < ApplicationRecord
  belongs_to :project
  belongs_to :org
end
