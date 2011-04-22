#encoding: utf-8

module Ib
  module Web
    # @todo document this class
    class Utils < Sinatra::Base
      include Db::Hw
      include Db::Persons

      set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'utils')

      # @todo Document this method
      get '/msg/:what/:kind' do |w,k|
        if w == 'flash'
          retval = flash[:msg]
        else
          retval = {:msg => {:txt => I18n.t(w, :data => params[:data]), :class => k}}.to_json
        end
        retval
      end
      # @todo Document this method
      get '/lang/:lang' do |l|
        I18n.locale = l.to_sym
        path = logged_in? ?  "#{lang_path}/ctrl" :  "#{lang_path}/"
        flash[:msg] = {:msg => {:txt => I18n.t('lang.change'), :class => "info"}}.to_json
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
          flash[:msg] = {:msg => {:txt => I18n.t('ibttn_auth.login_msg'), :class => "info"}}.to_json
          redirect "#{lang_path}/ctrl"
        else
          flash[:msg] = {:msg => {:txt => I18n.t('ibttn_auth.login_err'), :class => "error"}}.to_json
          redirect "#{lang_path}/"
        end
      end

      # Logout
      get '/logout' do
        session[:user] = nil
        flash[:msg] = {:msg => {:txt => I18n.t('ibttn_auth.logout_msg'), :class => "info"}}.to_json
        redirect "#{lang_path}/"
      end
    end
  end
end
