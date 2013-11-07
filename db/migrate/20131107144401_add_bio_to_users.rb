class AddBioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio, :string, :limit => 256
  end
end
