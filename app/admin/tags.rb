ActiveAdmin.register Tag do
  menu parent: 'Tags'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :name, :taggings_count

  index do
    selectable_column
    column :id
    column :name
    column :taggings_count
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :taggings_count
      row :created_at
      row :updated_at
    end
  end
  
end
