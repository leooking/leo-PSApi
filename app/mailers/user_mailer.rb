class UserMailer < ApplicationMailer

  def invite_user
    @user = params[:user]
    @site_url = ENV.fetch('MAILER_APP_URL')
    mail(to: @user.email, subject: 'You have been invited to Procurement Sciences!')
  end

  def verify_email
    @user = params[:user]
    @verify_link = ENV.fetch('MAILER_APP_URL')+"/verify_email?token=#{@user.confirmation_token}"
    mail(to: @user.email, subject: 'Please verify your email address')
  end

  def email_security_code
    @user = params[:user]
    @otp = params[:otp]
    mail(to: @user.email, subject: 'Procurement Sciences security code')
  end

  def password_reset_instructions
    @user = params[:user]
    @reset_link = ENV.fetch('MAILER_APP_URL')+"/session/password_reset?token=#{@user.password_reset_token}"
    mail(to: @user.email, subject: 'Procurement Sciences password reset instructions')
  end

  def failed_records_notification
    @file_name = params[:file_name]
    @records = params[:records]
    mail(to: "christian@procurementsciences.com", subject: 'Failed to process records from the CSV File')
  end

  def request_project_access
    @user = params[:user]
    @project = params[:project]
    @project_url = ENV.fetch('MAILER_APP_URL')+"/projects/#{@project.pid}"
    mail(to: @project.user.email, subject: "Project Access Request for #{@project.name}", from: "support@procurementsciences")
  end

end
