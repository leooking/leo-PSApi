class ChangeMfaDefaultToFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :mfa_enabled, from: true, to: false
  end
end
