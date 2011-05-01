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
        haml :index, :layout => request.xhr? ? false : :layout
      end
      # @todo nojs & js list records Document this method
      get '/list/:model/:page' do |m,p|
        login_required
        obj = modelize(m)
        ds = obj.name.include?("Log") ? obj.order(:id.desc).paginate(p.to_i,25) : obj.paginate(p.to_i,25)
        haml :list, :layout => request.xhr? ? false : :layout, :locals => {:ds  => ds, :path => m}
      end
      # @todo js edit Document this method
      get '/:model/:id' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        haml :get, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo js update Document this method
      put '/:model/:id' do |m,id|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo js new Document this method
      post '/:model/' do |m|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo Document this method
      delete '/:model/:id' do |m,id|
        login_required
        obj = modelize(m)
        r = obj[id.to_i]
        r.destroy
        flash[:msg] = {:msg => {:txt => I18n.t('mdl.delete', :data => r.model.name), :class => "info"}}.to_json
      end

      # @private Routes for browsers with js disabled
      #
      # @todo nojs new Document this method
      post '/:model/new' do |m|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo nojs edit Document this method
      get '/:model/:id/edit' do |m,id|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo nojs edit Document this method
      post '/:model/:id/edit' do |m,id|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #haml :edit, :layout => request.xhr? ? false : :layout, :locals => {:r  => r, :path => m}
      end
      # @todo nojs form for delete Document this method
      get '/:model/:id/delete' do |m,id|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #r.destroy
      end
      # @todo nojs delete Document this method
      post '/:model/:id/delete' do |m,id|
        #login_required
        #obj = modelize(m)
        #r = obj[id.to_i]
        #r.destroy
      end
    end
  end
end
