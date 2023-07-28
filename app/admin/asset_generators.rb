ActiveAdmin.register AssetGenerator do
  menu parent: 'Assets'
  permit_params :prompt_builder_visible, :resource_instructions_suffix, :resource_instructions_prefix, :prompt_assistant_visible, :my_resources_visible, :ext_resources_visible, 
  :user_guide_url, :window_size, :model_behavior, :resumable, :dynamic_preamble, :temperature, :max_tokens, :request_json, :home_showcase, :pid, :name, 
  :card_description, :asset_instruction, :sidebar_instruction, :convo_preface, :internal_notes, :pricing_tier, :provider, :endpoint, :sample_response, 
  :generator_type, :preamble, :response_trigger, :version, :state, :display_order,
  :global_preamble_default, :global_preamble_1st_party, :global_preamble_3rd_party, :custom_preambles_3rd_party, :global_temp_1st_party, :custom_temps_3rd_party, :action_specific_preambles

  index do
    selectable_column
    column :id
    column :pid
    column :display_order
    column :name
    column :resumable
    column :max_tokens
    column :temperature
    column :org_scoped do |g|
      g.orgs.count
    end
    column :generator_type
    column :my_resources_visible
    column :ext_resources_visible
    column :prompt_builder_visible
    column :state
    column :created_at
    column :updated_at
    actions
  end

  filter :id
  filter :pid
  filter :name
  filter :state
  filter :request_json
  filter :card_description
  filter :asset_instruction
  filter :sidebar_instruction
  filter :convo_preface
  filter :resource_instructions_prefix
  filter :resource_instructions_suffix
  filter :preamble
  filter :dynamic_preamble
  filter :response_trigger
  filter :global_preamble_default
  filter :global_preamble_1st_party
  filter :global_preamble_3rd_party
  filter :custom_preambles_3rd_party
  filter :global_temp_1st_party
  filter :custom_temps_3rd_party
  filter :action_specific_preambles

  form do |f|
    f.inputs 'Edit Asset Generator' do
      f.input :display_order
      f.input :global_preamble_default, hint: 'replaces preamble'
      f.input :global_preamble_1st_party
      f.input :global_preamble_3rd_party
      f.input :custom_preambles_3rd_party, as: :text, hint: 'A single JSON payload with keys as 3rd party name and value as text'
      f.input :global_temp_1st_party, hint: 'this is new'
      f.input :custom_temps_3rd_party, as: :text, hint: 'A single JSON payload with keys as 3rd party name and value as a float'
      f.input :action_specific_preambles, as: :text, hint: 'A single JSON payload (format TBD)'
      f.input :state, as: :select, collection: GENERATOR_STATES
      f.input :window_size, hint: 'Model context window size in tokens'
      f.input :max_tokens, hint: 'Determines maximum response length'
      f.input :temperature, label: 'Sampling temperature', hint: 'Max range 0.0 to 1.0. Higher values means the model will take more risks.'
      f.input :generator_type, as: :select, collection: GENERATOR_TYPES
      f.input :name
      f.input :user_guide_url
      f.input :resumable, label: 'Make assets created with this generator resumable'
      f.input :prompt_assistant_visible, label: 'Make prompt assistant button visible'
      f.input :my_resources_visible, label: 'Make my resources toggle visible'
      f.input :prompt_builder_visible, label: 'Make the prompt builder visible'
      f.input :ext_resources_visible, label: 'Make external resources toggle visible'
      f.input :model_behavior, as: :select, collection: GENERATOR_BEHAVIOR
      f.input :card_description, as: :text
      f.input :asset_instruction
      f.input :sidebar_instruction
      f.input :convo_preface
      f.input :resource_instructions_prefix, hint: 'This text instructs the model in the usage of the selected resources'
      f.input :resource_instructions_suffix, hint: 'This text reinforces the resource usage instructions to the model'
      f.input :preamble, hint: 'Prepended to the first prompt in the conversation'
      f.input :dynamic_preamble, hint: 'Blending user input with boilerplate.'
      f.input :response_trigger, as: :string, hint: 'Appended to all prompts'
      f.input :internal_notes
      # f.input :request_json
      # f.input :provider
      # f.input :endpoint
      # f.input :sample_response, label: 'Sample JSON response'
    end
    f.actions
  end
  
  show do
    attributes_table do
      row :id
      row :pid
      row :display_order
      row :resumable
      row :my_resources_visible
      row :ext_resources_visible
      row :model_behavior
      row :name
      row :user_guide_url
      row :version
      # row :home_showcase
      row :pricing_tier
      row :window_size
      row :max_tokens
      row :temperature
      row :generator_type
      row :card_description
      row :asset_instruction
      row :sidebar_instruction
      row :convo_preface
      row :resource_instructions_prefix
      row :resource_instructions_suffix
      row :preamble
      row :dynamic_preamble
      row :response_trigger
      row :internal_notes
      row :provider
      row :endpoint
      row :request_json
      row :sample_response
      row :state
      row :created_at
      row :updated_at
      row :global_preamble_default
      row :global_preamble_1st_party
      row :global_preamble_3rd_party
      row :custom_preambles_3rd_party
      row :global_temp_1st_party
      row :custom_temps_3rd_party
      row :action_specific_preambles
    end
  end
  
end