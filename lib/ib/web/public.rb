#encoding: utf-8

module Ib
  module Web
    # #IButton public pages
    # @todo document this class
    class Public < Sinatra::Base
      register Mixins
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(sinatra_views, 'public')

      # Just returns the index.html.
      #
      # In our case the index.hml is the README.md rendered using
      # the public layout.
      get '/' do
        haml :index
      end
    end # public
  end # web
end # ib

