#encoding: utf-8
module Ib
  module Web
    # @todo document this class
    class ControlTsk < Sinatra::Base
      register Mixins
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(sinatra_views, 'task')
      # @todo
      get "/" do
        login_required
        nodes = modelize("hw_node").all
        haml :index, :layout => request.xhr? ? false : :layout, :locals => {:nodes => nodes}
      end
      # @todo
      get "/partial" do
        case params[:opcode]
        when /02|03/
          # todo offer only connected devices
          devices = modelize("hw_device").all
        when '10'
          version = params[:file].split('_')[1].split('.')[0] rescue nil
        end
        haml :partial, :layout => false, :locals => {:opcode => params[:opcode],
                                                     :node => params[:node],
                                                     :devices => devices,
                                                     :version => version}
      end
      # @todo
      post "/execute" do
        @msg, @db_access_log, @log_serial_log = serial_msg(params)
        case @msg
        when String
          ibs_sock.write @msg if @msg.is_a? String
          Ib::Db::Log::Access.insert @db_access_log unless @db_access_log.empty?
          ibs_sock.logger.info("Web msg::#{@msg.chop}\\n::#{@log_serial_log}")
          haml '= "Last command:<br>#{@msg.chop}&#92;n<br><br> #{@db_access_log.join(" | ")}"' unless @db_access_log.empty?
        when Array
          ibs_sock.srv_upgrade(@msg[0],@msg[1].empty? ? nil : @msg[1])
          haml '= "Upgrade command sent to nodes:<br>&nbsp;&nbsp;&nbsp;&nbsp;Firmware: #{@msg[0]}<br>&nbsp;&nbsp;&nbsp;&nbsp;Version: #{@msg[1]}"'
        end
      end
    end
  end
end

