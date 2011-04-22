#encoding: utf-8

module Ib
  module Web
    # #Assets
    module Assets
      # #Sass/Compass Handler
      class Compass < Sinatra::Base
        set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'assets', 'stylesheets')

        # load Compass configuration file
        configure do
          compass_config = File.join(Ib::Config::WebConfig.sinatra_conf,'compass.rb')
          ::Compass.add_project_configuration(compass_config) \
            unless ::Compass.configuration.name == compass_config
        end

        # @todo Document this method
        get '/stylesheets/:name.css' do
          content_type 'text/css', :charset => 'utf-8'
          sass params[:name].to_sym, ::Compass.sass_engine_options
        end
      end

      # #Coffeescript Handler
      class Coffee < Sinatra::Base
        set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'assets','coffeescripts')

        # @todo Document this method
        get '/javascripts/:name.js' do
          content_type 'text/javascript', :charset => 'utf-8'
          coffee params[:name].to_sym
        end
      end
    end
  end
end
