ActiveAdmin.register Project do
  menu parent: 'Projects'

  actions :all, except: [:new, :edit, :destroy]
  
  permit_params :scope, :pid, :org_id, :group_id, :user_id, :name, :description, :agency, :project_type, :state, :start_date, :deadline, :objective

  index do
    selectable_column
    column :id
    column :pid
    column :org
    column :name
    column :team do |p|
      p.team.count
    end
    column :resources do |p|
      p.resources.count
    end
    column :assets do |p|
      p.assets.count
    end
    # column :interactions do |p|
    #   p.asset_interactions.count
    # end
    column :scope
    column :start_date
    column :deadline
    actions
  end  

  filter :id
  filter :pid
  filter :org
  filter :group
  filter :user
  filter :scope

  form do |f|
    f.inputs 'Edit Project' do
      f.input :name
      f.input :description
      f.input :objective
      f.input :state, as: :select, collection: PROJECT_STATES
      f.input :project_type, as: :select, collection: PROJECT_TYPES
      f.input :start_date
      f.input :deadline
      f.input :agency
      f.input :scope
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
      row :objective
      row :state, as: :select, collection: PROJECT_STATES
      row :project_type, as: :select, collection: PROJECT_TYPES
      row :start_date
      row :deadline
      row :agency
      row :scope
    end
  end
  
end
