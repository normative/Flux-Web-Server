class RefactorUsers < ActiveRecord::Migration
  def up
	execute "UPDATE users SET nickname = email WHERE nickname ISNULL"
	execute "UPDATE users SET lastname = firstname || ' '::varchar || lastname"
	rename_column :users, :lastname, :name
	rename_column :users, :nickname, :username
	remove_column :users, :firstname
	remove_column :users, :privacy
	execute "ALTER TABLE users ALTER COLUMN username SET NOT NULL"
	add_index :users, :username, unique: true
	add_index :users, :authentication_token, unique: true
  end

  def down
	remove_index :users, :authentication_token
	remove_index :users, :username
	execute "ALTER TABLE users ALTER COLUMN username DROP NOT NULL"
	rename_column :users, :name, :lastname
	rename_column :users, :username, :nickname
        add_column :users, :firstname, :string, :limit => 32
        add_column :users, :privacy, :boolean
  end
end
