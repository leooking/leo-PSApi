class FolderProject < ApplicationRecord
  belongs_to :folder
  belongs_to :project
end
