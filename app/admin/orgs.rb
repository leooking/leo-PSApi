ActiveAdmin.register Org do
  menu parent: 'Customers'
  permit_params :name, :url, :email_domain, :dash_message, :org_type

  index do
    selectable_column
    column :id
    column :pid
    column :name
    column :groups do |o|
      o.groups.count
    end
    column :staff do |o|
      o.users.count
    end
    column :assets do |o|
      o.org_assets.count  
    end
    column :private_generators do |o|
      o.private_generators.count  
    end
    column :org_type
    column :created_at
    actions
  end

  filter :id
  filter :pid
  filter :name
  filter :dash_message

  form do |f|
    f.inputs 'Edit Org' do
      f.input :org_type, as: :select, collection: ORG_TYPES
      f.input :name
      f.input :url
      f.input :email_domain
      f.input :dash_message, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :org_type
      row :name
      row :url
      row :email_domain
      row :dash_message
    end

    panel "Licenses (#{org.licenses.count})" do
      table_for org.licenses do
        column :id
        column :pid
        column :name do |l|
          link_to l.name, psci_staff_license_path(l)
        end
        column :quantity
        column :available do |l|
          l.allocations_available  
        end
        column :allocated do |l|
          l.allocated_quantity  
        end
        column :stripe_invoice_id
        column :issued_on
        column :expires_on
      end
    end

    panel "Users (#{org.users.count})" do
      table_for org.users do
        column :id
        column :pid
        column :name do |user|
          name = user.fname + ' ' + user.lname
          link_to name, psci_staff_user_path(user)
        end
        column :email do |user|
          link_to user.email, "mailto:#{user.email}"
        end
        column :group do |user|
          link_to user.group.name, psci_staff_group_path(user.group)
        end
        column :created_at
        column :updated_at
      end
    end

    panel "Groups (#{org.groups.count})" do
      table_for org.groups do
        column :id
        column :pid
        column :name do |group|
          link_to group.name, psci_staff_group_path(group)
        end
        column :total_members do |group|
          group.members.count
        end
        column :active_members do |group|
          group.active_members.count
        end
        column :created_at
        column :updated_at
      end
    end
  end

end
