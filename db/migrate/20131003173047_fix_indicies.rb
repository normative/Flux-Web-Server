class FixIndicies < ActiveRecord::Migration
  def up
	execute "DROP INDEX image_created_at_cluster_idx"
	execute "CREATE INDEX image_timestamp_cluster_idx ON images (time_stamp ASC NULLS LAST)"
	execute "ALTER TABLE images CLUSTER ON image_timestamp_cluster_idx"
	execute "CREATE INDEX images_tags_tag_id_idx ON images_tags (tag_id ASC NULLS LAST)"
	execute "CREATE INDEX images_tags_image_id_idx ON images_tags (image_id ASC NULLS LAST)"
  end

  def down
	execute "DROP INDEX images_tags_image_id_idx"
	execute "DROP INDEX images_tags_tag_id_idx"
	execute "DROP INDEX image_timestamp_cluster_idx"
	execute "CREATE INDEX image_created_at_cluster_idx ON images (created_at ASC NULLS LAST)"
	execute "ALTER TABLE images CLUSTER ON image_created_at_cluster_idx"
  end
end
