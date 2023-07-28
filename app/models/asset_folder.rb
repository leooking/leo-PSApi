class AssetFolder < ApplicationRecord
  belongs_to :asset
  belongs_to :folder
end
