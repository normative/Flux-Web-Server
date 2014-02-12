class AddApnDevTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :apns_device_token, :string, limit: 65
  end
end
