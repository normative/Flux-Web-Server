class AttachImages < ActiveRecord::Migration
  def up
    change_table :images do |t|
      t.has_attached_file :image
    end
  end
end
