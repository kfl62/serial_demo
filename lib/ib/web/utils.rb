#encoding: utf-8

module Ib
  module Web
    # @todo document this class
    class Utils < Sinatra::Base
      include Db::Hw
      include Db::Persons

      set :views, File.join(Ib.sinatra_views, 'utils')

      # @todo Document this method
      get '/msg/:what/:kind' do |w,k|
        if w == 'flash'
          retval = flash[:msg]
        else
          retval = {:msg => {:txt => t(w, :data => params[:data]), :class => k}}.to_json
        end
        retval
      end
      # @todo Document this method
      get '/lang/:lang' do |l|
        I18n.locale = l.to_sym
        path = logged_in? ?  "#{lang_path}/ctrl" :  "#{lang_path}/"
        flash[:msg] = {:msg => {:txt => t('lang.change'), :class => "info"}}.to_json
        redirect path
      end
      # Render login screen
      get '/login' do
        haml :login, :layout => request.xhr? ? false : :'layouts/default'
      end
      # Authentication
      post '/login' do
        if user = Admin.authenticate(params[:login_name], params[:password])
          session[:user] = user.id
          flash[:msg] = {:msg => {:txt => t('ib_auth.login_msg'), :class => "info"}}.to_json
          redirect "#{lang_path}/ctrl"
        else
          flash[:msg] = {:msg => {:txt => t('ib_auth.login_err'), :class => "error"}}.to_json
          redirect "#{lang_path}/"
        end
      end

      # Logout
      get '/logout' do
        session[:user] = nil
        flash[:msg] = {:msg => {:txt => t('ib_auth.logout_msg'), :class => "info"}}.to_json
        redirect "#{lang_path}/"
      end
      # Search
      get '/search/:where/:env' do |w,e|
        obj = modelize(w)
        obj.auto_search(e).to_json
      end
      # Search
      get '/search/:where/:id/:env' do |w,i,e|
        path = "#{w}/#{e}"
        what = modelize(w)[i]
        with = modelize(e)
        haml :partial, :layout => request.xhr? ? false : :'layouts/default', :locals => {:path => path,:what => what, :with => with}
      end
    end
  end
end

