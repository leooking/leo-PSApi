class AssetGroup < ApplicationRecord
  belongs_to :asset
  belongs_to :group
end
