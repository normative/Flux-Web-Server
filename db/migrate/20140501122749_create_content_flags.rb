class CreateContentFlags < ActiveRecord::Migration
  def change
    create_table :content_flags do |t|
      t.references :user, index: true
      t.references :image, index: true

      t.timestamps
    end
  end
end
