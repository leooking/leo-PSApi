ActiveAdmin.register Folder do
  menu parent: 'Admin'

  permit_params :name, :parent_id, :user_id, :org_id, :folder_type, :scope

    index do
    selectable_column
    column :id
    column :pid
    column :name
    column :parent
    column :folder_type
    column :scope
    column :resources do |f|
      f.resources.count
    end
    column :assets do |f|
      f.assets.count
    end
    column :projects do |f|
      f.projects.count
    end
    column :user
    actions
  end

  filter :id
  filter :pid
  filter :name
  filter :user
  filter :org
  filter :folder_type

  form do |f|
    f.inputs 'Edit Folder' do
      f.input :org_id
      f.input :user_id
      f.input :name
      f.input :parent
      f.input :folder_type, as: :select, collection: FOLDER_TYPES
    end
    f.actions
  end


  
end
