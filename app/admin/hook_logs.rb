ActiveAdmin.register HookLog do
  menu parent: 'Admin'
  actions :all, except: [:new, :edit, :destroy]
  permit_params :raw_event, :customer_id, :event_id, :event_type, :user_id
end
