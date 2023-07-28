ActiveAdmin.register AssetInteraction do
  menu parent: 'Assets'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :action, :third_party_data, :cosine_threshold, :token_cost, :custom_settings, :thumbs, :http_status, :asset_id, :asset_generator_id, :project_id, :user_id

  index do
    selectable_column
    column :id
    column :pid
    column :asset
    column :asset_generator
    column :user
    column :token_cost
    column :citation_data do |ai|
      ai.citation_data.length unless ai.citation_data.nil?
    end
    column :resource_data do |ai|
      ai.resource_data.length unless ai.resource_data.nil?
    end
    column :http_status
    actions
  end
  
  filter :user
  filter :asset_generator
  filter :resource_data
  filter :action
  filter :third_party_data
  filter :prompt
  filter :response
  
  show do
    attributes_table do
      row :id
      row :pid
      row :asset
      row :asset_generator
      row :user
      row :token_cost
      row :http_status
      row :preamble
      row :action
      row :use_my_resources
      row :use_ext_resources
      row :use_premium_resources
      row :prompt
      row :response
      row :thumbs
      row :cosine_threshold
      row :citation_data
      row :resource_data
      row :third_party_data
      row :created_at
      row :updated_at
    end
  end

end
