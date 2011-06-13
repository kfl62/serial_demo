# encoding: utf-8

module Ib
  module Web
    module Helpers
      # #Ib::Web::Heplers::Sinatra module
      # ##Descrition
      # ##Scope
      # Helper methods used in ... classes
      module Sinatra
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
        def one_to_many_update(what,with,params)
          what_id = params[:what_id].to_i
          with_id = params[:with_id].to_i
          what_model = modelize(what)[what_id]
          with_model = modelize(with)[with_id]
          what_method_base = what.split('_')[1]
          with_method_base = with.split('_')[1]
          if what_id == 0
            model = with_model
            method = what_method_base + "="
            data  = nil
          elsif with_id == 0
            model = what_model
            method = with_method_base + "="
            data  = nil
          else
            model = what_model
            method = with_method_base + "="
            data  = with_model
          end
          return [model,method,data]
        end
        # @todo
        def many_to_many_update(what,with,params)
          what_id = params[:what_id].to_i
          what_model = modelize(what)[what_id]
          with_model = modelize(with)
          with_method_base = with.split('_')[1]
          retval = []
          params[:with_id].each_pair do |k,v|
            if v == "0"
              method = "remove_" + with_method_base
              data = with_model[k.to_i]
              retval << [what_model,method,data]
            else
              method = "add_" + with_method_base
              data = with_model[k.to_i]
              dup = what_model.send("#{with_method_base}s_dataset").to_hash.has_key? k.to_i
              retval << [what_model,method,data] unless dup
            end
          end
          retval
        end
        # @todo
        def permission_update(what,params)
          what_id = params[:what_id].to_i
          what_model = modelize(what)[what_id]
          retval = []
          data = []
          with_model = nil
          method = ""
          params[:with_id].each_pair do |k,v|
            k = k.split('_').slice!(-2..-1).join('_')
            with_model = modelize(k)
            v.each_pair do |m,id|
              method = m + "="
              data = with_model[id.to_i]
            end
            retval << [what_model,method,data]
          end
          retval
        end
        # @todo
        def ibs_sock
          File.exists?(File.join(Ib.pid_dir,'ibutton_serial.sock')) ? \
            DRbObject.new_with_uri("drbunix://#{Ib.pid_dir}/ibutton_serial.sock") : nil
        end
        # @todo
        def serial_msg(params)
          opcode = params[:opcode]
          node = modelize("hw_node")[params[:node].to_i] if params [:node]
          node_sid = ("%04X" % node.sid).unpack("@2a2@0a2").pack("a2a2") if node
          device = modelize("hw_device")[params[:device].to_i] if params[:device]
          new_sid = ("%04X" % params[:new_sid]).unpack("@2a2@0a2").pack("a2a2") if params[:new_sid]
          msg = ">#{node_sid}#{opcode}"
          db_access_log  = []
          log_serial_log = []
          case opcode
          when "02"
            msg += "01" # arbitrary reader order, node expects this, obscure reason :)
            msg += "%02X" % device.order
            msg += "00" # reserved
            msg += "%08X" % device.task.taskId
            db_access_log = [nil,Time.now,"0",current_user.login_name,"web","interface",node.name,device.name,"ACCESS_OK",true]
            log_serial_log = "Admin: \"#{current_user.login_name}\" sent ACCESS_OK to node \"#{node.name}\"!"
          when "03"
            msg += "01" # arbitrary reader order, node expects this,obscure reason :)
            msg += "000000000000" # complete to 20 chars
            db_access_log = [nil,Time.now,"0",current_user.login_name,"web","interface",node.name,device.name,"ACCESS_DENY",false]
            log_serial_log = "Admin: \"#{current_user.login_name}\" sent ACCESS_DENY to node \"#{node.name}\"!"
          when "05"
            msg += "01" # arbitrary reader order, node expects this,obscure reason :)
            msg += new_sid
            msg += "00000000" # complete to 20 chars
            db_access_log = [nil,Time.now,"0",current_user.login_name,"New sid",params[:new_sid],"Old sid",node.sid,"NEWID_ACCEPTED",true]
          when "07"
            # not ready
            msg += "00000000000000" # placeholder for now
          when "10"
            msg = [params[:file], params[:new_version]]
          else
            # some error handling would be nice
          end
          msg += "\n" if msg.is_a? String
          [msg,db_access_log,log_serial_log]
        end
      end
    end
  end
end

