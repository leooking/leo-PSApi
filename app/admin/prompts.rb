ActiveAdmin.register Prompt do
  menu parent: 'Admin'
  permit_params :name, :description, :prompt_text, :scope, :user_id, :group_id, :org_id

    member_action :prompt, method: :get do
      email = resource.user.email
    end

  index do
    selectable_column
    column :id
    column :pid
    column :org
    column :group
    column :user
    column :name
    column :prompt_text
    column :scope
    column :created_at
    column :updated_at
    actions
  end

  filter :id
  filter :pid
  filter :name
  filter :description
  filter :prompt_text
  filter :scope

  form do |f|
    f.inputs 'Edit Prompt' do
      f.input :scope, as: :select, collection: PROMPT_SCOPES
      f.input :org, as: :select,    collection: Org.all.map {|o| [o.name, o.id]}
      f.input :group, as: :select,  collection: Group.all.map {|g| ["#{g.name} of #{g.org.name}", g.id]}
      f.input :user, as: :select,   collection: User.all.map {|u| ["#{u.name} of #{u.org.name}", u.id]}
      f.input :name
      f.input :description
      f.input :prompt_text
    end
    f.actions
  end
  
end
