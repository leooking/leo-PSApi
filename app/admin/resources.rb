ActiveAdmin.register Resource do
  menu parent: 'Resources'

  actions :all, except: [:new, :edit, :destroy]
  
  permit_params :scope, :embedding, :org_id, :user_id, :name, :description, :data_asset, :state, :source_url, :object_name, :raw_text

  controller do
    def destroy
      GcsService.new(resource: resource).remove_artifacts
      resource.destroy
      redirect_to psci_staff_resources_path, notice: 'resource successfully deleted'
    end
  end


  index do
    selectable_column
    column :id
    column :pid
    column :scope
    column :org
    column :name
    column :projects do |r|
      r.projects.count
    end
    column :user
    column :created_at
    actions
  end

  filter :id
  filter :pid
  filter :org
  filter :user
  filter :name
  filter :raw_text
  filter :embedding
  filter :scope

  form do |f|
    f.inputs 'Edit Resource' do
      f.input :org
      f.input :user
      f.input :name
      f.input :description
      # f.input :data_asset, as: :file
      f.input :source_url
      f.input :scope, as: :select, collection: RESOURCE_SCOPES
      f.input :state, as: :select, collection: RESOURCE_STATES
    end
    f.actions
  end


  show do
    attributes_table do
      row :id
      row :pid
      row :org
      row :name
      row :description
      row :data_asset
      row :source_url
      row :raw_text
      row :embedding
      row :scope
      row :state
      row :user
      row :created_at
      row :updated_at
    end
  end

end
