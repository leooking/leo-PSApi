ActiveAdmin.register AssetAutosave do
  menu parent: 'Assets'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :blob, :plain_text, :asset_id, :user_id

  index do
    selectable_column
    column :id
    column :user
    column :asset
    column :autosave do |a|
      a.plain_text.length if a.plain_text
    end
    actions
  end

  filter :plain_text
  filter :user
  filter :asset

  show do
    attributes_table do
      row :id
      row :user
      row :asset
      row :plain_text
      row :created_at
      row :updated_at
    end
  end
  
end
