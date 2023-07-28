# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "Recent Orgs" do
          ul do
            Org.last(20).reverse.map do |org|
              li link_to org.name, psci_staff_org_path(org.id)
            end
          end
        end
      end
      column do
        panel "Recent Users" do
          ul do
            User.last(20).reverse.map do |user|
              li link_to user.email, psci_staff_user_path(user.id)
            end
          end
        end
      end
      column do
        panel "Recent Assets" do
          ul do
            Asset.last(20).reverse.map do |asset|
              li link_to asset.name, psci_staff_asset_path(asset.id)
            end
          end
        end
      end
      column do
        panel "Recent Interactions" do
          ul do
            AssetInteraction.last(20).reverse.map do |inter|
              li link_to inter.pid, psci_staff_asset_interaction_path(inter.id)
            end
          end
        end
      end
    end
    

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
