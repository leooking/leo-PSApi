ActiveAdmin.register UserNotification do
  menu parent: 'Customers'

  permit_params :message, :message_type, :user_id, :read

  index do
    selectable_column
    column :id
    column :pid
    column :user
    column :read
    column :message
    column :message_type
    column :created_at
    actions
  end

  filter :id
  filter :pid
  filter :user
  filter :read
  filter :message
  filter :message_type

  form do |f|
    f.inputs 'Edit Resource' do
      f.input :message
      f.input :message_type
      f.input :user
      f.input :read
    end
    f.actions
  end
  
end
