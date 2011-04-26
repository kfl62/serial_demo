#encoding: utf-8
require "bundler/setup"
require "sequel"

task :environment do
  DB = Sequel.connect("sqlite://db/ibutton.sqlite3")
  ::Sequel.extension :migration
end

namespace :db do
  desc "Recreate tables with initial values"
  task :auto => :environment do
    puts "Performing automigration (reseting your db data)"
    ::Sequel::Migrator.run DB, "db/migrations", :target => 0
    ::Sequel::Migrator.run DB, "db/migrations"
    puts "Done! Your tables are ready with initial data..."
  end
end
namespace :console do
  desc "Irb with DB environment loaded"
  task :db do
    puts "Starting Irb with DB environment loaded"
    exec "irb -r ./lib/ib_db.rb"
  end
  desc "Irb with Serial environment loaded"
  task :serial do
    puts "Starting Irb with Serial environment loaded"
    exec "irb -r ./lib/ib_serial.rb"
  end
end
namespace :run do
  desc "Start web server"
  task :web do
    exec "rackup -sthin -p3000"
  end
end

