# encoding: utf-8

module Ib
  module Web
    module Helpers
      module Sinatra
        # #Sinatra helpers
        # Helper methods used in ... classes
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
              flash[:msg] = {:msg => {:txt => I18n.t('ibttn_auth.login_required'), :class => "error"}}.to_json
              redirect "#{lang_path}/"
              return false
            end
          end
          # @return [Admin] if `session[:user]` exists, else return `false`
          # @see #login_required
          def current_user
            if session[:user]
              Ib::Db::Persons::Admin[session[:user]]
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
            lang = I18n.locale
            lang == I18n.default_locale ? "" : "/#{lang}"
          end
          # @todo
          def modelize(str)
            m, c = str.split('_')
            guess_model(m).const_get(c.capitalize)
          end
          # @todo
          def guess_model(str)
            case str
            when "hw"       then Ib::Db::Hw
            when "persons"  then Ib::Db::Persons
            when "log"      then Ib::Db::Log
            else
              Object
            end
          end
        end
      end
    end
  end
end

