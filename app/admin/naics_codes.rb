ActiveAdmin.register NaicsCode do
  menu parent: 'Resources'
  config.sort_order = 'naics_2022_code'
  permit_params :naics_2022_code, :naics_2022_title

  index do
    selectable_column
    column :id
    column :naics_2022_code
    column :naics_2022_title
    actions
  end

  filter :naics_2022_code
  filter :naics_2022_title
  
  show do
    attributes_table do
      row :id
      row :naics_2022_code
      row :naics_2022_title
      row :created_at
      row :updated_at
    end
  end


end
