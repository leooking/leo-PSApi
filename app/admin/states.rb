ActiveAdmin.register State do
  menu parent: 'Resources'

  permit_params :name, :information_url, :homepage, :procurement, :abbreviation


  form do |f|
    f.inputs 'Edit State' do
      f.input :name
      f.input :information_url
      f.input :homepage
      f.input :procurement
      f.input :abbreviation
    end
    f.actions
  end

  action_item :only => :index do
    link_to 'Bulk provision via CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/states/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    response = CsvService.new(tempfile: params[:dump][:file]).provision_states
    if response.nil?
      flash[:error] = "An error occurred while processing the csv, the summary has been emailed to you"
    else
      flash[:notice] = "Successfully created #{response} states"
    end
    redirect_to :action => :index
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :name
      row :abbreviation
      row :information_url do |state|
        link_to 'Information URL', state.information_url, target: "_blank"
      end
      row :homepage do |state|
        link_to 'State homepage', state.homepage, target: "_blank"
      end
      row :procurement do |state|
        link_to 'Procurement URL', state.procurement, target: "_blank"
      end
      row :created_at
      row :updated_at
    end

    panel "State Agencies (#{state.state_agencies.count})" do
      table_for state.state_agencies do
        column :id
        column :pid
        column :name do |agency|
          link_to agency.name, psci_staff_state_agency_path(agency)
        end
        column :agency_url do |agency|
          link_to 'Agency URL', agency.url, target: "_blank"
        end
        column :created_at
        column :updated_at
      end
    end

  end


end
