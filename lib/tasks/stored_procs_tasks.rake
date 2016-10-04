namespace :stored_procs do
  desc "Load stored procedures"
  task :load do
    Dir.glob("/dbProcs/*.sql").each do | procfile |
      sql = File.read(procfile)
      statements = sql.split(/;$/)
      statements.pop # remote empty line
      ActiveRecord::Base.transaction do
        statements.each do |statement|
          connection.execute(statement)
        end
      end
    end
  end
end
