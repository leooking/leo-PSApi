ActiveAdmin.register Allocation do
  menu parent: 'Admin'
  actions :all, except: [:show, :edit, :destroy]
  permit_params :org_id, :license_id, :user_id

  index do
    selectable_column
    column :id
    column :org
    column :license
    column :user
    column :expires_on do |a|
      a.license.expires_on if a.license
    end
    column :created_at
    actions
  end

  filter :org
  filter :license
  filter :user

  form do |f|
    f.inputs 'Edit Allocation' do
      f.input :org
      f.input :license, as: :select, collection: License.all.map {|l| ["#{l.name} of #{l.org.name}", l.org.id]}
      f.input :user, as: :select, collection: User.all.map {|u| ["#{u.name} of #{u.org.name}", u.id]}
    end
    f.actions
  end

end
