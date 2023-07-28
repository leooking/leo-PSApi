ActiveAdmin.register Group do
  menu parent: 'Customers'

  permit_params :org_id, :name, :pid, :user_id

  controller do
    def destroy
      if resource.members.present?
        redirect_to psci_staff_groups_path, notice: 'Group contains members, cannot'
      else
        resource.destroy
        redirect_to psci_staff_groups_path, notice: 'Group successfully deleted'
      end
    end
  end

  index do
    selectable_column
    column :id
    column :pid
    column :name
    column :org
    column :members do |g|
      g.members.count
    end
    column :creator do |g|
      g.creator
    end
    actions
  end

  form do |f|
    f.inputs 'Edit Group' do
      f.input :org
      f.input :name
    end
    f.actions
  end


  show do
    attributes_table do
      row :id
      row :pid
      row :org
    end
    panel "Users (#{group.members.count})" do
    table_for group.members do
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
