#! /usr/bin/env ruby
#encoding: utf-8
require "sequel"

module Ib
  # #Ib::Db module
  # ##Description:
  # ##Scope:
  # @todo document this module
  module Db

    #case DbConfig.database
    #when 'sqlite'
      require 'sqlite3'
      # DB = Sequel.connect("sqlite://#{DbConfig.sqlite_path}/#{DbConfig.sqlite_file}") unless defined?(DB)
      DB = Sequel.connect("sqlite://db/ibutton.sqlite3") unless defined?(DB)
   #when 'mysql'
      #require 'mysql'
      #DB = Sequel.connect("mysql://.....") unless defined?(DB)
    #else
      #puts "Wrong database configuration"
    #end

    #Dir.glob(File.join(DbConfig.db_models,'*.rb')).each do |file|
      #require file
    #end

    Sequel.extension :pagination

    autoload :Hw,       'db/hw'
    autoload :Log,      'db/log'
    autoload :Persons,  'db/persons'

  end
end

