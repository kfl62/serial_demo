#! /usr/bin/env ruby
#encoding: utf-8
require 'web/helpers/haml'
require 'web/helpers/sinatra'

module Ib
  # #Ib::Web module
  # ## Scope
  #   A module wich includes four {http://www.sinatrarb.com/ Sinatra::Base} sub classes
  #   {Ib::Web::Public}, {Ib::Web::Control}, {Ib::Web::ControlTsk}  and {Ib::Web::Utils}
  #   ...
  # @todo document this model
  module Web
    # initialize options
    config_file = File.join(Ib.app_root,'config','simple_conf.yaml')
    if File.exists?(config_file)
      opts = YAML.load_file(config_file)["Web"]
      opts.each_pair do |k,v|
        Ib.opt.send k + "=",v
      end
    Ib.opt.device =  YAML.load_file(config_file)["Serial"]["device"] || "/dev/ttyS0"
    Ib.opt.baud_rate =  YAML.load_file(config_file)["Serial"]["baud_rate"] || 115200
    end
    Haml::Helpers.class_eval('include Helpers::Haml')
    Sinatra::Base.class_eval('include Helpers::Sinatra')
    Sinatra::Base.set(
      :root => Ib.app_root,
      :haml => {:format => :html5, :attr_wrapper => '"'}
    )
    # @todo document this method
    def self.server
      Rack::Builder.new do
        use Rack::Session::Cookie, :secret => 'zsdgryst34kkufklfSwsqwess'
        use Rack::Flash
        use Rack::Rewrite do
          rewrite %r{^/\w{2}/utils}, '/utils'
          rewrite %r{^/\w{2}/ctrl},  '/ctrl'
          rewrite %r{^/\w{2}/},      '/'
        end

        map '/utils' do
          run Utils.new
        end
        map '/ctrl' do
          map '/tsk' do
            run ControlTsk.new
          end
          map '/' do
            run Control.new
          end
        end
        map '/' do
          run Public.new
        end
      end
    end
    autoload :Control,      'web/control'
    autoload :ControlTsk,   'web/control_tsk'
    autoload :Public,       'web/public'
    autoload :Utils,        'web/utils'
    autoload :Assets,       'web/assets'
  end
end


