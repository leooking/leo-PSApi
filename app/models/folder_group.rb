class FolderGroup < ApplicationRecord
  belongs_to :folder
  belongs_to :group
end
