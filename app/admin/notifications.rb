ActiveAdmin.register Notification do
  menu parent: 'Admin'
  permit_params :name, :display_text, :state, :modal, :top_bar, :top_bar_color 

  index do
    selectable_column
    column :id
    column :name
    column :state
    column :modal
    column :top_bar
    column :top_bar_color
    actions
  end

  filter :display_text
  filter :state
  filter :modal
  filter :top_bar
  filter :top_bar_color

  form do |f|
    f.inputs 'Edit Project' do
      f.input :name, hint: 'An organization aid, optional'
      f.input :display_text, hint: 'Be careful about overall length!'
      f.input :state, as: :select, collection: NOTIFICATION_STATES, hint: 'Only one active at a time!'
      f.input :modal, label: 'Display text in modal'
      f.input :top_bar, label: 'Display text in top-bar'
      f.input :top_bar_color, as: :select, collection: TOP_BAR_COLOR, hint: 'Set blank for default purple color'
    end
    f.actions
  end

  
end
