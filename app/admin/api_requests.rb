ActiveAdmin.register ApiRequest do
  menu parent: 'Calls-n-crawls'

  permit_params :name, :description, :notes, :request_json, :endpoint

  index do
    selectable_column
    column :id
    column :pid
    column :name
    actions
  end  

  filter :id
  filter :pid
  filter :name
  filter :description
  filter :notes
  filter :endpoint
  
  form do |f|
    f.inputs 'Edit API Request' do
      f.input :name
      f.input :description
      f.input :notes
      f.input :request_json
      f.input :endpoint
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :name
      row :description
      row :notes
      row :request_json
      row :endpoint
    end
    panel "API results (#{api_request.api_results.count})" do
      table_for api_request.api_results do
        column :pid do |api_result|
          link_to api_result.pid, psci_staff_api_result_path(api_result)
        end
        column :http_status
        column :created_at
        column :updated_at
      end
    end
  end

end
