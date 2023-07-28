ActiveAdmin.register AssetGeneratorLog do
  menu parent: 'Assets'
  
  actions :all, except: [:new, :edit, :destroy]

  permit_params :expense, :http_status
end
