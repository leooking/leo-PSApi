###Data

**Sam.Gov**

- PSci entity ID FWB5E3B6HJA8

Parse and insert CSV 06/08/23 on stag and 06/09/23 on prod

- [Daily Active Sam.Gov Opportunities CSV](https://sam.gov/data-services/Contract%20Opportunities/datagov?privacy=Public)
- Headers
  - `"notice_id","title","sol_number","agency","cgac","sub_tier","fpds_code","office","aac_code","posted_date","type","base_type","archive_type","archive_date","set_aside_code","set_aside","response_deadline","naics_code","classification_code","pop_street_address","pop_city","pop_state","pop_zip","pop_country","active","award_number","award_date","award_dollars","awardee","primary_contact_title","primary_contact_fullname","primary_contact_email","primary_contact_phone","primary_contact_fax","secondary_contact_title","secondary_contact_fullname","secondary_contact_email","secondary_contact_phone","secondary_contact_fax","organization_type","state","city","zip_code","country_code","additional_info_link","link","description"`
  - `"NoticeId","Title","Sol#","Department/Ind.Agency","CGAC","Sub-Tier","FPDS Code","Office","AAC Code","PostedDate","Type","BaseType","ArchiveType","ArchiveDate","SetASideCode","SetASide","ResponseDeadLine","NaicsCode","ClassificationCode","PopStreetAddress","PopCity","PopState","PopZip","PopCountry","Active","AwardNumber","AwardDate","Award$","Awardee","PrimaryContactTitle","PrimaryContactFullname","PrimaryContactEmail","PrimaryContactPhone","PrimaryContactFax","SecondaryContactTitle","SecondaryContactFullname","SecondaryContactEmail","SecondaryContactPhone","SecondaryContactFax","OrganizationType","State","City","ZipCode","CountryCode","AdditionalInfoLink","Link","Description"`
- Our headers
  - `notice_id,title,sol_number,agency,cgac,sub_tier,fpds_code,office,aac_code,posted_date,oppty_type,base_type,archive_type,archive_date,set_aside_code,set_aside,response_deadline,naics_code,classification_code,pop_street_address,pop_city,pop_state,pop_zip,pop_country,active,award_number,award_date,award_dollars,awardee,primary_contact_title,primary_contact_fullname,primary_contact_email,primary_contact_phone,primary_contact_fax,secondary_contact_title,secondary_contact_fullname,secondary_contact_email,secondary_contact_phone,secondary_contact_fax,organization_type,state,city,zip_code,country_code,additional_info_link,link,description`
- SQL INSERT INTO
  "sam_dot_govs" (
    "notice_id",
    "title",
    "sol_number",
    "agency",
    "cgac",
    "sub_tier",
    "fpds_code",
    "office",
    "aac_code",
    "posted_date",
    "oppty_type",
    "base_type",
    "archive_type",
    "archive_date",
    "set_aside_code",
    "set_aside",
    "response_deadline",
    "naics_code",
    "classification_code",
    "pop_street_address",
    "pop_city",
    "pop_state",
    "pop_zip",
    "pop_country",
    "active",
    "award_number",
    "award_date",
    "award_dollars",
    "awardee",
    "primary_contact_title",
    "primary_contact_fullname",
    "primary_contact_email",
    "primary_contact_phone",
    "primary_contact_fax",
    "secondary_contact_title",
    "secondary_contact_fullname",
    "secondary_contact_email",
    "secondary_contact_phone",
    "secondary_contact_fax",
    "organization_type",
    "state",
    "city",
    "zip_code",
    "country_code",
    "additional_info_link",
    "link",
    "description",
    "created_at",
    "updated_at")
VALUES
  ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38
