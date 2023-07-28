class AssetOrg < ApplicationRecord
  belongs_to :asset
  belongs_to :org
end
