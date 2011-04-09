#encoding: utf-8

require "bundler/setup"
require "sinatra/base"
require "haml"

require "./lib/web_helpers/ib_web_helpers_haml.rb"

Haml::Helpers.class_eval("include IbWebModule::Haml::Helpers")
Sinatra::Base.set(:root, "../")
Sinatra::Base.set(:views, "./lib/web_views/")
Sinatra::Base.set(:haml, :format => :html5, :attr_wrapper => '"')

class IbWeb < Sinatra::Base
  get '/' do
    haml :index, :layout => :'./layouts/default'
  end
  
  get '/sql' do
    haml :sql, :layout => :'./layouts/default'
  end
end

