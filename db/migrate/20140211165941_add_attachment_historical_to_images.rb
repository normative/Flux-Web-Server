class AddAttachmentHistoricalToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :historical
    end
  end

  def self.down
    drop_attached_file :images, :historical
  end
end
