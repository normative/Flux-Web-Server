class AddAttachmentFeaturesToImages < ActiveRecord::Migration
  def self.up
    change_table :images do |t|
      t.attachment :features
    end
  end

  def self.down
    drop_attached_file :images, :features
  end
end
