ActiveAdmin.register ApiResult do
  menu parent: 'Calls-n-crawls'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :api_request_id, :json_response, :http_status

  index do
    selectable_column
    column :id
    column :pid
    column :api_request
    column :http_status
    column :created_at
    # column :updated_at
    actions
  end  
  
  filter :id
  filter :pid
  filter :api_request_id
  
  show do
    attributes_table do
      row :id
      row :pid
      row :api_request
      row :json_response
      row :http_status
      row :created_at
      # row :updated_at
    end
  end

end
