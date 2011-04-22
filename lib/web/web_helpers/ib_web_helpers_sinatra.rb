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
          
          def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
            if first_letter_in_uppercase
              lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
            else
              lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
            end
          end          
          def constantize(camel_cased_word)
            names = camel_cased_word.split('::')
            names.shift if names.empty? || names.first.empty?

            constant = Object
            names.each do |name|
              constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
            end
            constant
          end
          def modelize(str)
            a, b = str.split('_')
            if a == 'hw'
              Ib::Db::Hw.const_get(b.capitalize)
            else
              Ib::Db::Persons.const_get(b.capitalize)
            end
          end
        end
      end
    end
  end
end

