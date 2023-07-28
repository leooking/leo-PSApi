class OrgAssetGenerator < ApplicationRecord
  belongs_to :org
  belongs_to :asset_generator
end
