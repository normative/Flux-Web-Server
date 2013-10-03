class UpdateImageidToBigint < ActiveRecord::Migration
  def up
	change_column :images, :id, 'bigint'
	change_column :images_tags, :id, 'bigint'
	change_column :images_tags, :image_id, 'bigint'
  end

  def down
	change_column :images, :id, :integer
	change_column :images_tags, :id, :integer
	change_column :images_tags, :image_id, :integer
  end
end
