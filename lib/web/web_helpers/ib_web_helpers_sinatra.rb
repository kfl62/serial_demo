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
              flash[:msg] = {:msg => {:txt => I18n.t('ib_auth.login_required'), :class => "error"}}.to_json
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
          # @return [String] translated string
          def t(*args)
            I18n::t(*args)
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
          # @todo
          def check_association(what,with,what_id,with_id)
            if what_id == "0"
              model = modelize(with)[with_id.to_i]
              data  = nil
            elsif with_id == "0"
              model = modelize(what)[what_id.to_i]
              data  = nil
            else
              model = modelize(what)[what_id.to_i]
              data  = modelize(with)[with_id.to_i]
            end
            return [model,method,data]
          end
        end
      end
    end
  end
end

