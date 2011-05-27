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
        if params[:opcode] =~ /02|03/
          # todo offer only connected devices
          devices = modelize("hw_device").all
        end
        haml :partial, :layout => false, :locals => {:opcode => params[:opcode], :node => params[:node], :devices => devices}
      end
      # @todo
      post "/execute" do
        @msg, @db_access_log, @db_error_log = serial_msg(params)
        if Ib.ibs
          ibs.write @msg
        else
          Ib::Serial::Server.open(Ib.opt.device,Ib.opt.baud_rate) do |ibs|
            ibs.write @msg
          end
        end
        haml '= "Last command:<br>#{@msg.chop}&#92;n<br><br> #{@db_access_log.join(" | ")}"' unless @db_access_log.empty?
      end

    end
  end
end

