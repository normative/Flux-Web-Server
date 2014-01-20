class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.integer :connections_id
      t.integer :connection_type
      t.integer :state

      t.timestamps
    end
  end
end
