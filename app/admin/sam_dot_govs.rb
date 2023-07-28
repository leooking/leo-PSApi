ActiveAdmin.register SamDotGov do
  menu parent: 'Resources'

  # actions :all, except: [:new, :edit, :destroy]

  index do
    selectable_column
    column :notice_id
    column :title
    column :naics_code
    column :posted_date
    column :response_deadline
    actions
  end
  
  filter :notice_id
  filter :title
  filter :description
  filter :oppty_type
  filter :agency
  filter :sub_tier
  filter :full_parent_path_name
  filter :sol_number
  filter :naics_code
  filter :posted_date
  filter :response_deadline
  
  show do
    attributes_table do
      row :notice_id
      row :title
      row :naics_code
      row :link
      row :additional_info_link
      row :sol_number
      row :description
      row :api_desc_link
      row :agency
      row :cgac
      row :sub_tier
      row :fpds_code
      row :office
      row :full_parent_path_name
      row :aac_code
      row :posted_date
      row :oppty_type
      row :base_type
      row :archive_type
      row :archive_date
      row :set_aside_code
      row :set_aside
      row :response_deadline
      row :classification_code
      row :pop_street_address
      row :pop_city
      row :pop_state
      row :pop_zip
      row :pop_country
      row :active
      row :award_number
      row :award_date
      row :award_dollars
      row :awardee
      row :primary_contact_title
      row :primary_contact_fullname
      row :primary_contact_email
      row :primary_contact_phone
      row :primary_contact_fax
      row :secondary_contact_title
      row :secondary_contact_fullname
      row :secondary_contact_email
      row :secondary_contact_phone
      row :secondary_contact_fax
      row :organization_type
      row :state
      row :city
      row :zip_code
      row :country_code
      row :created_at
      row :updated_at
    end
  end


end
