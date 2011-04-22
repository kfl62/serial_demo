#encoding: utf-8

module Ib
  module Web
    # #IButton public pages
    # @todo document this class
    class Public < Sinatra::Base
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'public')

      # @todo Document this method
      get '/' do
        haml :index
      end

    end
  end
end

