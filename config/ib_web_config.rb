#encoding: utf-8

app_root = File.expand_path('..',File.dirname(__FILE__)) 
app_lib = File.join(app_root,'lib')

Dir['config','lib','lib/*/'].each do |dir|
  dir = File.join(app_root,dir)
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

require 'bundler/setup'
require 'sinatra/base'
require 'json'

require 'haml'
require 'compass'
require 'ib_web_helpers_haml'
require 'ib_web_helpers_sinatra'
Haml::Helpers.class_eval('include IbWebModule::Haml::Helpers')
Sinatra::Base.class_eval("include IbWebModule::Sinatra::Helpers")
Sinatra::Base.set(:root, app_root)
Sinatra::Base.set(:views, File.join(app_lib,'web_views'))
Sinatra::Base.set(:haml, :format => :html5, :attr_wrapper => '"')
Sinatra::Base.configure do
  compass_config = File.join(File.dirname(__FILE__), 'compass.rb')
  Compass.add_project_configuration(compass_config) \
    unless Compass.configuration.name == compass_config
end

require 'i18n'
I18n.load_path += Dir.glob(File.join(app_root, 'lib','web_translations','*.yml'))
I18n.load_path += Dir.glob(File.join(app_root, 'lib','db_models','*.yml'))
I18n.default_locale = :en

require 'ib_web_public'
require 'ib_web_utils'
require 'ib_web_control'
require 'ib_web_control_tsk'

