ActiveAdmin.register Role do
  menu parent: 'Admin'

  permit_params :name, :notes

  index do
    selectable_column
    column :id
    column :pid
    column :name
    column :permissions do |r|
      r.permissions.count
    end
    actions
  end
  
  form do |f|
    f.inputs 'Edit Role' do
      f.input :name
      f.input :notes
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :name
      row :users do |r|
        r.users.count
      end
    end
    panel "Permissions (#{role.permissions.count})" do
      table_for role.permissions do
        column :id
        column :pid
        column :name do |perm|
          link_to perm.name, psci_staff_permission_path(perm)
        end
      end
    end
  end
  
end
