ActiveAdmin.register User do
  menu parent: 'Customers'
  permit_params :fname, :lname, :email, :org_id, :group_id, :email_verified, :mfa_enabled, group_membership_ids: []

  actions :all, except: [:new]

  index do
    selectable_column
    column :id
    column :pid
    column :org
    column :name do |u|
      link_to u.name, psci_staff_user_path(u)
    end
    column :email do |u|
      link_to u.email, "mailto:#{u.email}"
    end
    column :group_memberships do |u|
      u.group_memberships.count
    end
    column :permissions do |u|
      u.permissions.count
    end
    column :interaction_24h_total
    column :token_24h_total
    column :license_expiry do |u|
      if u.license
        u.license.expires_on  if u.license
      else
        '---'
      end
    end
    column :last_login
    column :login_count
    column :mfa_enabled
    actions
  end

  action_item :only => :index do
    link_to 'Bulk provision via CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/users/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    response = CsvService.new(tempfile: params[:dump][:file]).provision_users
    if response.nil?
      flash[:error] = "An error occurred while processing the csv, the summary has been emailed to you"
    else
      flash[:notice] = "Successfully created #{response} users"
    end
    redirect_to :action => :index
  end

  filter :id
  filter :pid
  filter :org
  filter :fname
  filter :lname
  filter :email_verified

  form do |f|
    f.inputs 'Edit User' do
      f.input :fname
      f.input :lname
      f.input :email
      f.input :email_verified
      f.input :org
      f.input :group_memberships, label: 'This is WIP, do not use today!', hint: 'this group must be from that Org!'
      f.input :mfa_enabled
    end
    f.actions
  end

  controller do
    def destroy
      resource.projects.destroy_all
      RoleUser.where(user_id: resource.id).destroy_all
      Asset.where(user_id: resource.id).destroy_all
      AssetInteraction.where(user_id: resource.id).destroy_all
      AssetGeneratorLog.where(user_id: resource.id).destroy_all
      GroupUser.where(user_id: resource.id).destroy_all
      Note.where(user_id: resource.id).destroy_all
      Price.where(user_id: resource.id).destroy_all
      ProjectTeam.where(user_id: resource.id).destroy_all
      Project.where(user_id: resource.id).destroy_all
      GcsService.new(resource: resource).remove_artifacts
      Resource.where(user_id: resource.id).destroy_all
      Score.where(user_id: resource.id).destroy_all
      resource.destroy
      redirect_to psci_staff_users_path
    end
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :org
      row :group
      row :fname
      row :lname
      row :email
      row :email_verified
      row :mfa_enabled
      row :license do |u|
        link_to u.license.name, psci_staff_license_path(u.license) if u.license
      end
      row :license_expires do |u|
        u.license_expires                                          if u.license
      end
      row:asset_24h_total
      row:interaction_24h_total
      row:token_24h_total
      row:asset_lifetime_total
      row:interaction_lifetime_total
      row:token_lifetime_total
      row :last_login
      row :login_count
      row :created_at
      row :updated_at
    end
    panel "Group Memberships (#{user.group_memberships.count})" do
      table_for user.group_memberships do
        column :id
        column :pid
        column :name
      end
    end
    panel "Roles (#{user.roles.count})" do
      table_for user.roles do
        column :id
        column :pid
        column :role_name do |role|
          link_to role.name, psci_staff_role_path(role)
        end
      end
    end
  end

end
