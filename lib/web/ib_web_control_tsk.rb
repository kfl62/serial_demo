#encoding: utf-8
require 'ib_serial'
module Ib
  module Web
    # @todo document this class
    class ControlTsk < Sinatra::Base
      include Ib::Serial
      use Assets::Compass
      use Assets::Coffee

      set :views, File.join(Ib::Config::WebConfig.sinatra_views, 'task')
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
        #puts params.inspect
        case params[:opcode]
        when /05|07/
          sid = "%04d" % params[:node]
          sid = sid[2,2] + sid[0,2]
          if params[:opcode] == "05"
            newid = "%04d" % params[:new_sid]
            newid = newid[2,2] + newid[0,2]
            rest = "01#{newid}00000000"
          else
            rest = ""
          end
        when /02|03/
          if params[:opcode] == "02"
            sid = "%04d" % params[:node]
            sid = sid[2,2] + sid[0,2]
            response_device = "%02X" %params[:device]
            rest = "01#{response_device}0000000001"
          else
            sid = "0100"
            rest = "01000000000000"
          end
        else
          # todo
        end
        opcode = params[:opcode]
        msg = ">#{sid}#{opcode}#{rest}\n"
        Ib::Serial::Server.open(SerialConfig.dev,SerialConfig.baud) do |ibs|
          ibs.write msg
        end
      end
    end
  end
end

