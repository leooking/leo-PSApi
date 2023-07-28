ActiveAdmin.register RoleUser do
  menu parent: 'Admin'
  permit_params :user_id, :role_id
  
end
