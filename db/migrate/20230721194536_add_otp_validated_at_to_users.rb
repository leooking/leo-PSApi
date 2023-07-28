class AddOtpValidatedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :otp_validated_at, :datetime
  end
end
