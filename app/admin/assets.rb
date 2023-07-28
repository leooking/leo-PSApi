ActiveAdmin.register Asset do
  menu parent: 'Assets'
  
  actions :all, except: [:new, :edit, :destroy]

  permit_params :scope, :total_tokens, :frozen, :project_id, :user_id, :asset_generator_id, :name, :description, :source, :link, :asset_type, :state, :objective

  index do
    selectable_column
    column :id
    column :pid
    column :user
    column :name
    column :total_tokens
    column :interactions do |a|
      a.asset_interactions.count
    end
    column :scope
    column :asset_generator
    actions
  end

  filter :id
  filter :pid
  filter :user
  filter :project
  filter :name
  filter :state
  filter :scope
  filter :asset_generator

  form do |f|
    f.inputs 'Edit Project' do
      f.input :name
      f.input :description
      f.input :objective
      f.input :state, as: :select, collection: ASSET_STATES
      f.input :scope, as: :select, collection: ASSET_SCOPES
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :user
      row :name
      row :total_tokens
      row :objective
      row :scope
      row :created_at
      row :updated_at
    end
    panel "Interactions (#{asset.asset_interactions.count})" do
      table_for asset.asset_interactions do
        column :pid do |interaction|
          link_to interaction.pid, psci_staff_asset_interaction_path(interaction)
        end
        column :asset
        column :asset_generator
        column :user
        column :token_cost
        column :citation_data do |interaction|
          interaction.citation_data.length unless interaction.citation_data.nil?
        end
        column :resource_data do |interaction|
          interaction.resource_data.length unless interaction.resource_data.nil?
        end
        column :http_status
        column :created_at
        column :updated_at
      end
    end
  end

end
