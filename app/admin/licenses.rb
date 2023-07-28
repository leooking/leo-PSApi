ActiveAdmin.register License do
  menu parent: 'Customers'
  actions :all, except: [:destroy]
  permit_params :name, :note, :quantity, :stripe_invoice_id, :issued_on, :expires_on, :org_id

  index do
    selectable_column
    column :id
    column :pid
    column :org
    column :quantity
    column :available do |l|
      l.allocations_available
    end
    column :allocated do |l|
      l.allocated_quantity
    end
    column :issued_on
    column :expires_on
    actions
  end

  filter :id
  filter :pid
  filter :org
  filter :issued_on
  filter :expires_on

  form do |f|
    f.inputs 'Edit License' do
      f.input :name
      f.input :note
      f.input :quantity
      f.input :org
      f.input :stripe_invoice_id
      f.input :issued_on
      f.input :expires_on
    end
    f.actions
  end

  show do
    attributes_table do
      row :org
      row :id
      row :pid
      row :name
      row :quantity
      row :allocations_available
      row :allocated_quantity
      row :stripe_invoice_id
      row :issued_on
      row :expires_on
    end

    panel "Licensees (#{license.users.count})" do
      table_for license.users do
        column :id
        column :pid
        column :name do |user|
          name = user.fname + ' ' + user.lname
          link_to name, psci_staff_user_path(user)
        end
        column :email do |user|
          link_to user.email, "mailto:#{user.email}"
        end
        column :created_at
        column :updated_at
      end
    end
  end
end
