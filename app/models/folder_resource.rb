class FolderResource < ApplicationRecord
  belongs_to :folder
  belongs_to :resource
end
