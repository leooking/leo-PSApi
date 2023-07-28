ActiveAdmin.register OrgAssetGenerator do
  menu parent: 'Customers'
  permit_params :org_id, :asset_generator_id
  
end
