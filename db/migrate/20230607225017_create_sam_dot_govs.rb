# "NoticeId","Title","Sol#","Department/Ind.Agency","CGAC","Sub-Tier","FPDS Code","Office","AAC Code","PostedDate","Type","BaseType","ArchiveType","ArchiveDate","SetASideCode","SetASide","ResponseDeadLine","NaicsCode","ClassificationCode","PopStreetAddress","PopCity","PopState","PopZip","PopCountry","Active","AwardNumber","AwardDate","Award$","Awardee","PrimaryContactTitle","PrimaryContactFullname","PrimaryContactEmail","PrimaryContactPhone","PrimaryContactFax","SecondaryContactTitle","SecondaryContactFullname","SecondaryContactEmail","SecondaryContactPhone","SecondaryContactFax","OrganizationType","State","City","ZipCode","CountryCode","AdditionalInfoLink","Link","Description"
class CreateSamDotGovs < ActiveRecord::Migration[7.0]
  def change
    create_table :sam_dot_govs do |t|
      t.string :notice_id
      t.string :title
      t.string :sol_number
      t.string :agency
      t.string :CGAC
      t.string :sub_tier
      t.string :fpds_code
      t.string :office
      t.string :aac_code
      t.datetime :posted_date
      t.string :type
      t.string :base_type
      t.string :archive_type
      t.datetime :archive_date
      t.string :set_aside_code
      t.string :set_aside
      t.datetime :response_deadline
      t.string :naics_code
      t.string :classification_code
      t.string :pop_street_address
      t.string :pop_city
      t.string :pop_state
      t.string :pop_zip
      t.string :pop_country
      t.string :active
      t.string :award_number
      t.datetime :award_date
      t.integer :award_dollars
      t.string :awardee
      t.string :primary_contact_title
      t.string :primary_contact_fullname
      t.string :primary_contact_email
      t.string :primary_contact_phone
      t.string :primary_contact_fax
      t.string :secondary_contact_title
      t.string :secondary_contact_fullname
      t.string :secondary_contact_email
      t.string :secondary_contact_phone
      t.string :secondary_contact_fax
      t.string :organization_type
      t.string :state
      t.string :city
      t.string :zip_code
      t.string :country_code
      t.string :additional_info_link
      t.string :link
      t.string :description

      t.timestamps
    end
    add_index :sam_dot_govs, :notice_id
    add_index :sam_dot_govs, :sol_number
    add_index :sam_dot_govs, :naics_code
  end
end
