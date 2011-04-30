#encoding: utf-8

module Ib
  module Web
    # #IButton Control Center
    # @todo Document this class
    class Control < Sinatra::Base
      include Db::Hw
      include Db::Persons
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'control')

      # @todo Document this method
      get '/' do
        login_required
        haml :index
      end
      # @todo Document this method
      get '/list/*/*' do
        login_required
        model = params[:splat][0]
        obj = modelize(model)
        pg = params[:splat][1].to_i
        ds = obj.name.include?("Log") ? obj.order(:id.desc).paginate(pg,25) : obj.paginate(pg,25)
        haml :list, :layout => request.xhr? ? false : :layout, :locals => {:ds  => ds, :path => model}
      end
    end
  end
end
