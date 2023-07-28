ActiveAdmin.register_page "Dashboard Message" do
  menu parent: 'Admin'

  content title: "Org Dashboard Message" do
    render "admin/dashboard_message/form", layout: "active_admin"
  end

  page_action :add_dashboard_message, method: :post do
    begin
      org_pids = params[:dashboard_message][:org_ids]
      message = params[:dashboard_message][:message]
      if message.present?
        Org.where(pid: org_pids).update(dash_message: message)
        flash[:notice] = "Successfully updated dashboard message for orgs"
      else
        raise Exception.new "Message must be present"
      end
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to "/psci_staff"
  end

end
