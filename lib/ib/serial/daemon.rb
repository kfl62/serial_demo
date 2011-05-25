#encoding: utf-8
module Ib
  module Serial
    class Daemon
      include Utils

      class << self
        def run
          self.new
        end
      end

      def initialize
        self.options = {
          :device => '/dev/ttyS0',
          :baud_rate => 115200,
          :debug => false
        }
        start
      end
      def start
        puts "\nConnected to: #{options[:device]}\n"
        trap("INT"){
          stop
          exit
        }
        trap("TERM"){
          stop
          exit
        }
        self.ibs = Server.new(options[:device], options[:baud_rate])
        msg = self.ibs.gets
        if msg.length == 22
          self.ibs.handle(msg)
        end
      end
      def stop
        puts "\nClosed connection to: #{options[:device]} !"
        self.ibs.close
      end
    end
  end
end
