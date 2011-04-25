#encoding: utf-8
require 'bundler/setup'
require 'ostruct'
require 'sinatra/base'
require 'rack-flash'
require 'rack/rewrite'
require 'haml'
require 'compass'
require 'rdiscount'
require 'json'
require 'i18n'
require 'sequel'
require 'serialport'

Dir['config','lib','lib/**/*'].each do |dir|
  dir = File.join(File.expand_path('..',File.dirname(__FILE__)),dir)
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

module Ib
  module Config
    app_path = File.expand_path('..',File.dirname(__FILE__))

    WebConfig = OpenStruct.new(
      :sinatra_root         => app_path,
      :sinatra_conf         => File.join(app_path, 'config'),
      :sinatra_views        => File.join(app_path, 'lib', 'web', 'web_views'),
      :sinatra_translations => File.join(app_path, 'lib', 'web', 'web_translations'),
      :i18n_default         => 'en',
      :db_models            => File.join(app_path, 'lib', 'db')
    )

    SerialConfig = OpenStruct.new(
      :dev       => '/dev/ttyS0',
      :baud      => 115200
    )

    DbConfig = OpenStruct.new(
      :database         => 'sqlite',
      :sqlite_path      => 'db',
      :sqlite_file      => 'ibutton.sqlite3',
      :mysql_dbname     => "ibutton",
      :mysql_username   => "root",
      :mysql_password   => "ibutton",
      :db_models        => File.join(app_path, 'lib', 'db')
    )

    I18n.load_path += Dir.glob(File.join(WebConfig.sinatra_translations, '*.yml'))
    I18n.load_path += Dir.glob(File.join(WebConfig.db_models, '*.yml'))
    I18n.default_locale = :en
  end
end

