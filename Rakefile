#encoding: utf-8

task :default => "doc"

desc "Generate API docs"
task :doc do
  puts "Generating API docs"
  exec "yardoc"
  puts "Done. Docs are in ./public/docs/ folder"
end
task :environment do
  require "bundler/setup"
  require "sequel"
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
    puts "Starting thin on port 3000"
    exec "rackup -sthin -p3000"
  end
  desc "Watching serial port"
  task :serial do
    require "./lib/ib_serial.rb"
    puts "Listening on #{Ib::Serial::SerialConfig.dev}"
    while true
      Ib::Serial.server
    end
  end
end

