class AddTimeStampToImage < ActiveRecord::Migration
  def change
    add_column :images, :time_stamp, :timestamp
  end
end
