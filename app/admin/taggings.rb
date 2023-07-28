ActiveAdmin.register Tagging do
  menu parent: 'Tags'

  permit_params :tag_id, :taggable_type, :taggable_id, :tagger_type, :tagger_id, :context, :tenant
  
  index do
    selectable_column
    column :id
    column :context
    column :created_at
    column :updated_at
    # actions
  end

end
