# encoding: utf-8
=begin
#Sinatra helpers
Just for convenience (namespace)
=end
module IbWebModule
  # #Sinatra helpers
  # Just for convenience (namespace)
  module Sinatra
    # #Sinatra helpers
    # Helper methods used in TrstSys, TrstSysTsk classes
    module Helpers
      # @return [String] return `Hash` key,value pairs as a `String`
      def hash_to_query_string(hash)
        hash.collect {|k,v| "#{k}=#{v}"}.join('&')
      end
      # @return [Boolean] true if `current_user`, else set `flash[:msg]` to error
      #   and redirect to public pages
      # @see #current_user
      def login_required
        if current_user
          return true
        else
          flash[:msg] = {:msg => {:txt => I18n.t('trst_auth.login_required'), :class => "error"}}.to_json
          redirect "#{lang_path}/"
          return false
        end
      end
      # @return [TrstUser] if `session[:user]` exists, else return `false`
      # @see #login_required
      def current_user
        if session[:user]
          #TrstUser.find(session[:user])
        else
          return false
        end
      end
      # @return [Boolean] check if `session[:user]` is initialized
      def logged_in?
        !!session[:user]
      end
      # Set language prefix for browser's path
      # @return [String]
      def lang_path
        lang = I18n.locale.to_s
        lang == I18n.default_locale ? "" : "/#{lang}"
      end

    end
  end
 end

