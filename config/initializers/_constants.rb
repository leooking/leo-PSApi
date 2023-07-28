
ORG_TYPES           = %w[smb enterprise reseller]
RESOURCE_STATES     = %w[lost waiting ordered active deprecated]
PROJECT_TYPES       = %w[bid pricing research other]
PROJECT_STATES      = %w[proposed active complete archived]
ASSET_TYPES         = %w[one_shot conversation]
ASSET_STATES        = %w[requested returned approved rejected]
GENERATOR_TYPES     = %w[single convo multi intellibid-2 winmore-2 smartcheck resource ask_shipley ask_lohfeld]
GENERATOR_STATES    = %w[pre_launch active deprecated]
GENERATOR_BEHAVIOR  = %w[use_prior_interactions no_prior_interactions]
PROMPT_SCOPES       = %w[mine group org featured]
ASSET_SCOPES        = %w[mine group org]  # default org
RESOURCE_SCOPES     = %w[mine group org]  # default org
PROJECT_SCOPES      = %w[mine group org]  # default org
FOLDER_SCOPES       = %w[mine group org]  # default org
FOLDER_TYPES        = %w[resource asset project]
SHARED_RESOURCES    = [{display_name: 'SAM.GOV Opportunities', payload_value: 'sam_dot_gov'},{display_name: 'USA Spending Notices', payload_value: 'usa_spending'}]
# SHARED_RESOURCES    = [{display_name: 'Defense Federal Acquisition Supplement (DFARS)', payload_value: 'dfars'}, {display_name: 'Federal Acquisition Regulation (FAR)', payload_value: 'far'}, {display_name: 'SAM.GOV Opportunities', payload_value: 'sam_dot_gov'},{display_name: 'USA Spending Notices', payload_value: 'usa_spending'}]
CRAWL_STATES        = %w[proposed active paused deprecated]
NOTIFICATION_STATES = %w[active inactive]
TOP_BAR_COLOR       = %w[bg-red-500 bg-sky-300 bg-slate-400]
PIPELINE_STATES     = %w[active archived]
PIPELINE_STAGES     = ['RESEARCHING', 'IN-PIPELINE', 'ACTIVE/RESPONDING', 'SUBMITTED/PENDING AWARD', 'AWARDED']
