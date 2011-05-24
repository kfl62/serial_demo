#encoding: utf-8
require './ib_serial'
module Ib
  module Serial
    class Daemon
      include Ib::Serial::Utils

      class << self
        def run
          self.new
        end
      end

      def initialize
        self.options = {
          :device => "/dev/ttyS0",
          :baud_rate => 115200,
          :debug => false
        }
        start
      end
      def start
        puts "Start watching serial communication on: #{options.dev}"
        trap("INT"){
          stop
          exit
        }
        trap("TERM"){
          stop
          exit
        }
        @ibs = Ib::Serial::Server.new(options.device, options.baud_rate)
        msg = @ibs.gets
        if msg.length == 22
          @ibs.handle(msg)
        end
      end
      def stop
        puts "Connection to  #{options.dev} closed!"
        @ibs.close
      end
    end
  end
end

Ib::Serial::Daemon.run