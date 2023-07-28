ActiveAdmin.register PermissionRole do
  menu parent: 'Admin'

  permit_params :role_id, :permission_id
  
end
