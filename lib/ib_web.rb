#! /usr/bin/env ruby
#encoding: utf-8

require './config/ib_config'
require './lib/ib_db'

module Ib
  # @todo document this model
  module Web
    include Config
    require 'ib_web_assets'
    require 'ib_web_public'
    require 'ib_web_utils'
    require 'ib_web_control'
    require 'ib_web_control_tsk'

    require 'ib_web_helpers_haml'
    require 'ib_web_helpers_sinatra'
    Haml::Helpers.class_eval('include Helpers::Haml::Helpers')
    Sinatra::Base.class_eval('include Helpers::Sinatra::Helpers')
    Sinatra::Base.set(:root, WebConfig.sinatra_root)
    Sinatra::Base.set(:haml, :format => :html5, :attr_wrapper => '"')

    I18n.load_path += Dir.glob(File.join(WebConfig.sinatra_translations, '*.yml'))
    I18n.load_path += Dir.glob(File.join(WebConfig.db_models, '*.yml'))
    I18n.default_locale = :en

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
  end
end

# run as standalone rb file
#if __FILE__ == $0
  #run Ib::Web.server
#end

