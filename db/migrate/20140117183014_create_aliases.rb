class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.integer :user_id
      t.text :alias_name
      t.integer :service_id

      t.timestamps
    end
  end
end
