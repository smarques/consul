# The task assumes you have figaro application.yml config in Capistrano shared folder
# https://github.com/laserlemon/figaro

require 'date'
require 'sshkit'

namespace :db do
  desc "Backup your PostgreSQL database to ~/"
  task :dump_postgres do
    on roles(:db) do
      # @dbconf = dbconfig
      @dbconf = dbconfig
     
      dbuser = @dbconf["username"]
      dbname = @dbconf["database"]
      dbhost = @dbconf["host"]
      dbpass = @dbconf["password"]

      # feel free to add required flags for pg_dump
      # http://www.postgresql.org/docs/9.4/static/app-pgdump.html

      within '~/' do
        fname = "consul_backup_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.sql"
        fullname = "/home/rails/consul/db-backups/" + fname;
        
        execute :pg_dump,
                "-W -U #{dbuser} -h #{dbhost} -F c", # --format=plain --quote-all-identifiers --clean --if-exists
                "#{dbname} > \"#{fullname}\"",
                interaction_handler: {
                  'Password: ' => "#{dbpass}\n"
                }
        download! fullname, 'db-backups/' + fname
        execute :rm, "#{fullname}"
      end
      
    end
  end

  # pg_restore -d decidim -U postgres -W -c -h 127.0.0.1 --no-owner --role=postgres  db-backups/decidim_backup_2020-03-25-16-47-16
  # extract password from figaro shared config file
  def dbconfig
    YAML::load(
      capture :cat, "#{shared_path}/config/database.yml"
    )['production']
  end

end