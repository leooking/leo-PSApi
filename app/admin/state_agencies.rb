ActiveAdmin.register StateAgency do
  menu parent: 'Resources'

  permit_params :name, :url, :state_id

  form do |f|
    f.inputs 'Edit State' do
      f.input :name
      f.input :url
      f.input :state
    end
    f.actions
  end

end
