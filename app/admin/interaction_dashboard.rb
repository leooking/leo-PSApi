ActiveAdmin.register AssetInteraction, as: "InteractionDashboard" do
  menu parent: 'Assets'
  config.sort_order = 'created_at_desc'

  actions :all, except: [:new, :edit, :destroy]

  filter :prompt
  filter :response
  filter :org
  filter :user
  filter :asset_generator_name

  index do
    selectable_column
    column(:asset) { |ai| link_to ai.asset.name, psci_staff_asset_path(ai.asset_id) }
    column(:user) { |ai| link_to ai.user.email, psci_staff_user_path(ai.user_id) }
    column(:org) { |ai| link_to ai.user.org.name, psci_staff_org_path(ai.user.org_id) }
    column(:asset_generator_name) { |ai| link_to ai.asset_generator.name, psci_staff_asset_generator_path(ai.asset_generator_id) }
    column "Prompt",  :prompt
    column "Response",  :response
    column 'created at', :created_at
    actions
  end

  # eager loading records to prevent n+1
   controller do
    def scoped_collection
      super.includes :user, :asset_generator, :asset
    end
  end
end