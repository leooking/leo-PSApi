class AddMfaCodeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :mfa_enabled, :boolean, default: true
  end
end
