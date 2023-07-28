ActiveAdmin.register Permission do
  menu parent: 'Admin'

  permit_params :name, :notes

  index do
    selectable_column
    column :id
    column :pid
    column :name
    column :roles do |p|
      p.roles.count
    end
    actions
  end
  
  form do |f|
    f.inputs 'Edit Permission' do
      f.input :name
      f.input :notes
    end
    f.actions
  end

  
end
