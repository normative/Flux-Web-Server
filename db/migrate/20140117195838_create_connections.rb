class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.integer :connections_id
      t.integer :am_following
      t.integer :friend_state
      t.timestamps
    end
  end
end
