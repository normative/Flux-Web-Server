class RefactorConnections < ActiveRecord::Migration
  def up
	execute <<-SQL
		UPDATE connections 
			SET friend_state = 1 
			WHERE friend_state = 0;
		DROP TRIGGER cleanconnections_trig ON connections;
	SQL
	remove_column :connections, :am_following
	rename_column :connections, :friend_state, :following_state
  end

  def down
	ActiveRecord::IrreversibleMigration
  end
end
