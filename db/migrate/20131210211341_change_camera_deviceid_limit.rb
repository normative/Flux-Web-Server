class ChangeCameraDeviceidLimit < ActiveRecord::Migration
  def change
	change_column :cameras, :deviceid, :string, :limit => 64, null => false
  end
end
