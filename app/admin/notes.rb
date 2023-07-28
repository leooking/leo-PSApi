ActiveAdmin.register Note do
  permit_params :user_id, :text

  actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    column :id
    column :pid
    column :org do |note|
      note.notable.org.name
    end
    column :notable_type
    column :notable_name do |note|
      note.notable.name
    end
    column :created_at
    column :updated_at
  end

  filter :notable_type

end
