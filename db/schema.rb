# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_24_230559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "agencies", force: :cascade do |t|
    t.string "agency_name"
    t.string "agency_code"
    t.string "sub_department"
    t.string "acronym"
    t.integer "employment"
    t.string "website_url"
    t.string "strategic_plan_url"
    t.string "strategic_plan_url_additional"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "allocations", force: :cascade do |t|
    t.integer "org_id"
    t.integer "license_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_requests", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "notes"
    t.jsonb "request_json"
    t.string "endpoint"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_results", force: :cascade do |t|
    t.integer "api_request_id", null: false
    t.jsonb "json_response"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "http_status"
  end

  create_table "asset_autosaves", force: :cascade do |t|
    t.binary "blob"
    t.text "plain_text"
    t.integer "asset_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_folders", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "folder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_folders_on_asset_id"
    t.index ["folder_id"], name: "index_asset_folders_on_folder_id"
  end

  create_table "asset_generator_logs", force: :cascade do |t|
    t.integer "asset_generator_id", null: false
    t.integer "loggable_id", null: false
    t.integer "user_id", null: false
    t.jsonb "json_response", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "http_status"
    t.string "loggable_type", default: "", null: false
    t.string "expense"
  end

  create_table "asset_generators", force: :cascade do |t|
    t.string "name"
    t.text "asset_instruction"
    t.string "provider"
    t.string "endpoint"
    t.string "generator_type"
    t.string "state"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pricing_tier"
    t.string "card_description"
    t.string "internal_notes"
    t.jsonb "sample_response"
    t.boolean "home_showcase", default: false
    t.text "convo_preface"
    t.text "sidebar_instruction"
    t.text "preamble"
    t.text "response_trigger"
    t.string "version"
    t.jsonb "request_json"
    t.integer "max_tokens"
    t.float "temperature", default: 0.0
    t.text "dynamic_preamble"
    t.boolean "resumable", default: false
    t.string "model_behavior"
    t.jsonb "toggle_config", default: {"my_resources"=>false, "ext_resources"=>false}
    t.integer "window_size"
    t.string "user_guide_url"
    t.boolean "my_resources_visible", default: false
    t.boolean "ext_resources_visible", default: false
    t.boolean "prompt_assistant_visible", default: false
    t.text "resource_instructions_prefix"
    t.text "resource_instructions_suffix"
    t.string "global_preamble_default"
    t.string "global_preamble_1st_party"
    t.string "global_preamble_3rd_party"
    t.jsonb "custom_preambles_3rd_party"
    t.float "global_temp_1st_party"
    t.float "global_temp_3rd_party"
    t.jsonb "custom_temps_3rd_party"
    t.jsonb "action_specific_preambles"
    t.float "display_order"
    t.boolean "prompt_builder_visible", default: false
  end

  create_table "asset_groups", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_interactions", force: :cascade do |t|
    t.string "custom_settings"
    t.text "prompt"
    t.text "response"
    t.string "http_status"
    t.integer "asset_id", null: false
    t.integer "asset_generator_id", null: false
    t.integer "project_id"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pid", null: false
    t.boolean "thumbs"
    t.jsonb "resource_data"
    t.jsonb "citation_data"
    t.text "preamble"
    t.integer "token_cost", default: 0
    t.float "cosine_threshold"
    t.jsonb "third_party_data", default: {}
    t.string "action"
    t.boolean "use_my_resources", default: false
    t.boolean "use_ext_resources", default: false
    t.boolean "use_premium_resources", default: false
    t.integer "asset_revision_id"
    t.index ["asset_generator_id"], name: "index_asset_interactions_on_asset_generator_id"
    t.index ["asset_id"], name: "index_asset_interactions_on_asset_id"
  end

  create_table "asset_orgs", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_projects", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asset_revisions", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.integer "asset_generator_id", null: false
    t.integer "project_id"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pid", null: false
    t.integer "parent_id"
    t.boolean "ignore", default: false
  end

  create_table "asset_users", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assets", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id", null: false
    t.string "name"
    t.string "description"
    t.string "source"
    t.string "link"
    t.string "asset_type"
    t.string "state"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "objective"
    t.integer "asset_generator_id"
    t.boolean "frozen", default: false
    t.integer "total_tokens", default: 0
    t.string "scope", default: "group"
    t.index ["scope"], name: "index_assets_on_scope"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "crawl_instructions", force: :cascade do |t|
    t.string "name"
    t.string "notes"
    t.string "target"
    t.integer "depth", default: 1
    t.integer "days_between_crawls"
    t.jsonb "collector", default: {}
    t.jsonb "selectors", default: {}
    t.string "state", default: "suggested"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crawl_logs", force: :cascade do |t|
    t.datetime "crawled_at"
    t.integer "crawl_id"
    t.integer "crawled_pages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crawl_results", force: :cascade do |t|
    t.integer "crawl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page_title"
    t.string "url"
    t.string "raw_text"
  end

  create_table "crawls", force: :cascade do |t|
    t.string "crawl_name"
    t.string "target_url"
    t.integer "max_pages"
    t.integer "max_depth"
    t.datetime "last_crawl"
    t.string "scheduling_memo"
    t.string "state", default: "proposed"
    t.string "pid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resource_id"
  end

  create_table "favorite_assets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorite_prompts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "prompt_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "folder_groups", force: :cascade do |t|
    t.integer "folder_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "folder_projects", force: :cascade do |t|
    t.integer "folder_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_folder_projects_on_folder_id"
  end

  create_table "folder_resources", force: :cascade do |t|
    t.integer "folder_id"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_folder_resources_on_folder_id"
  end

  create_table "folders", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.integer "user_id"
    t.integer "org_id"
    t.string "folder_type"
    t.string "scope", default: "group"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_type"], name: "index_folders_on_folder_type"
    t.index ["parent_id"], name: "index_folders_on_parent_id"
    t.index ["scope"], name: "index_folders_on_scope"
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "group_projects", force: :cascade do |t|
    t.integer "group_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_resources", force: :cascade do |t|
    t.integer "group_id"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_users", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
  end

  create_table "groups", force: :cascade do |t|
    t.integer "org_id"
    t.string "name"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "hook_logs", force: :cascade do |t|
    t.jsonb "raw_event"
    t.string "customer_id"
    t.string "event_id"
    t.string "event_type"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade do |t|
    t.string "name"
    t.string "note"
    t.integer "quantity"
    t.string "stripe_invoice_id"
    t.datetime "issued_on"
    t.datetime "expires_on"
    t.integer "org_id", null: false
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "naics_codes", force: :cascade do |t|
    t.integer "naics_2022_code"
    t.string "naics_2022_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", force: :cascade do |t|
    t.integer "user_id"
    t.string "text"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notable_type", null: false
    t.integer "notable_id", null: false
    t.index ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "name"
    t.string "display_text"
    t.string "state", default: "inactive"
    t.boolean "modal", default: true
    t.boolean "top_bar", default: true
    t.string "top_bar_color", default: "bg-slate-400"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_asset_generators", force: :cascade do |t|
    t.integer "org_id"
    t.integer "asset_generator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_resources", force: :cascade do |t|
    t.integer "org_id"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orgs", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "email_domain"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "dash_message"
    t.string "org_type", default: "smb"
  end

  create_table "permission_roles", force: :cascade do |t|
    t.integer "role_id"
    t.integer "permission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pid", null: false
    t.string "notes"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "pipelines", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sam_dot_gov_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0
    t.integer "stages", default: 0
    t.bigint "group_id"
    t.string "pid", null: false
    t.index ["group_id"], name: "index_pipelines_on_group_id"
    t.index ["sam_dot_gov_id"], name: "index_pipelines_on_sam_dot_gov_id"
    t.index ["user_id"], name: "index_pipelines_on_user_id"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.string "component"
    t.string "name"
    t.string "description"
    t.integer "dollars"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bid_reference"
  end

  create_table "project_assets", force: :cascade do |t|
    t.integer "project_id"
    t.integer "asset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_orgs", force: :cascade do |t|
    t.integer "project_id"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_resources", force: :cascade do |t|
    t.integer "project_id"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_teams", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_users", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.integer "org_id"
    t.integer "user_id"
    t.string "project_type"
    t.string "state"
    t.string "name"
    t.string "description"
    t.string "objective"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "agency"
    t.datetime "deadline"
    t.integer "group_id"
    t.datetime "start_date"
    t.string "scope", default: "group"
    t.index ["scope"], name: "index_projects_on_scope"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.text "prompt_text"
    t.string "scope", default: "group"
    t.integer "user_id", null: false
    t.integer "group_id"
    t.integer "org_id"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resource_users", force: :cascade do |t|
    t.integer "resource_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.integer "org_id"
    t.integer "user_id"
    t.string "state"
    t.string "name"
    t.string "description"
    t.string "objective"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_url"
    t.string "sha256_file"
    t.string "gcs_file"
    t.jsonb "data_asset"
    t.text "raw_text"
    t.jsonb "embedding", default: {}
    t.string "scope", default: "group"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.index ["lft"], name: "index_resources_on_lft"
    t.index ["parent_id"], name: "index_resources_on_parent_id"
    t.index ["rgt"], name: "index_resources_on_rgt"
    t.index ["scope"], name: "index_resources_on_scope"
    t.index ["sha256_file"], name: "index_resources_on_sha256_file"
    t.index ["user_id"], name: "index_resources_on_user_id"
  end

  create_table "role_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pid", null: false
    t.string "notes"
  end

  create_table "sam_dot_govs", force: :cascade do |t|
    t.string "notice_id"
    t.string "title"
    t.string "sol_number"
    t.string "agency"
    t.string "cgac"
    t.string "sub_tier"
    t.string "fpds_code"
    t.string "office"
    t.string "aac_code"
    t.datetime "posted_date"
    t.string "oppty_type"
    t.string "base_type"
    t.string "archive_type"
    t.datetime "archive_date"
    t.string "set_aside_code"
    t.string "set_aside"
    t.datetime "response_deadline"
    t.string "naics_code"
    t.string "classification_code"
    t.string "pop_street_address"
    t.string "pop_city"
    t.string "pop_state"
    t.string "pop_zip"
    t.string "pop_country"
    t.string "active"
    t.string "award_number"
    t.datetime "award_date"
    t.bigint "award_dollars"
    t.string "awardee"
    t.string "primary_contact_title"
    t.string "primary_contact_fullname"
    t.string "primary_contact_email"
    t.string "primary_contact_phone"
    t.string "primary_contact_fax"
    t.string "secondary_contact_title"
    t.string "secondary_contact_fullname"
    t.string "secondary_contact_email"
    t.string "secondary_contact_phone"
    t.string "secondary_contact_fax"
    t.string "organization_type"
    t.string "state"
    t.string "city"
    t.string "zip_code"
    t.string "country_code"
    t.string "additional_info_link"
    t.string "link"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_parent_path_name"
    t.string "api_desc_link"
    t.string "pid"
    t.index ["naics_code"], name: "index_sam_dot_govs_on_naics_code"
    t.index ["notice_id"], name: "index_sam_dot_govs_on_notice_id"
    t.index ["oppty_type"], name: "index_sam_dot_govs_on_oppty_type"
    t.index ["pid"], name: "index_sam_dot_govs_on_pid"
    t.index ["posted_date"], name: "index_sam_dot_govs_on_posted_date"
    t.index ["response_deadline"], name: "index_sam_dot_govs_on_response_deadline"
    t.index ["set_aside_code"], name: "index_sam_dot_govs_on_set_aside_code"
    t.index ["sol_number"], name: "index_sam_dot_govs_on_sol_number"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.string "evaluator"
    t.string "name"
    t.string "description"
    t.string "attribute"
    t.integer "score"
    t.integer "maximum"
    t.integer "weight"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bid_reference"
  end

  create_table "state_agencies", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.bigint "state_id", null: false
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_state_agencies_on_state_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "information_url"
    t.string "homepage"
    t.string "procurement"
    t.string "abbreviation"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context"
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_notifications", force: :cascade do |t|
    t.string "message"
    t.string "message_type"
    t.integer "user_id"
    t.boolean "read", default: false
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "fname"
    t.string "lname"
    t.string "email", default: "", null: false
    t.boolean "email_verified", default: false
    t.datetime "last_login"
    t.integer "login_count", default: 0
    t.string "password_hash"
    t.string "confirmation_token"
    t.string "auth_token"
    t.string "refresh_token"
    t.string "password_reset_token"
    t.integer "org_id"
    t.integer "group_id"
    t.string "pid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "dashboard_home", default: true
    t.string "otp_secret"
    t.boolean "mfa_enabled", default: false
    t.datetime "otp_validated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["pid"], name: "index_users_on_pid", unique: true
  end

  add_foreign_key "pipelines", "groups"
  add_foreign_key "pipelines", "sam_dot_govs"
  add_foreign_key "pipelines", "users"
  add_foreign_key "state_agencies", "states"
  add_foreign_key "taggings", "tags"
end
