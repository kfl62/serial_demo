#! /usr/bin/env ruby
#encoding: utf-8
require "./config/ib_config"

module Ib
  # @todo document this module
  module Db
    include Config

    case DbConfig.database
    when 'sqlite'
      require 'sqlite3'
      DB = Sequel.connect("sqlite://#{DbConfig.sqlite_path}/#{DbConfig.sqlite_file}") unless defined?(DB)
    when 'mysql'
      require 'mysql'
      DB = Sequel.connect("mysql://.....") unless defined?(DB)
    else
      puts "Wrong database configuration"
    end

    Dir.glob(File.join(DbConfig.db_models,'*.rb')).each do |file|
      require file
    end

    Sequel.extension :pagination

  end
end

