ActiveAdmin.register Agency do
  menu parent: 'Resources'

  permit_params :agency_name, :agency_code, :sub_department, :acronym, :employment, :website_url, :strategic_plan_url, :strategic_plan_url_additional, :pid

end
