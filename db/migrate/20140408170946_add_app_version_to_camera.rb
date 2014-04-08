class AddAppVersionToCamera < ActiveRecord::Migration
  def change
    add_column :cameras, :app_version, :string, :limit => 16
  end
end
