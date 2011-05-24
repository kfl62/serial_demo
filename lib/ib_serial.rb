#! /usr/bin/env ruby
#encoding: utf-8
require 'logger'
require './serial/ib_serial_utils'
# require './config/ib_config'
# require './lib/ib_db'

module Ib
  # @todo document this module
  module Serial
    # @todo
    class SerialError < StandardError; end

    VERSION = "0.1.0"
    @@options = {}

    class << self
      # @todo
      def options
        @@options
      end
      # @todo
      def options=(val)
        @@options = val
      end
      # @todo
      def logger
        return @@logger if defined?(@@logger)
        FileUtils.mkdir_p(File.dirname(log_path))
        @@logger = Logger.new(log_path)
        @@logger.level = Logger::Info if options[:debug] == false
        @@logger
      rescue
         @@logger = Logger.new(STDOUT)
      end
      # @todo
      def base_dir
        options[:base_dir] || File.join(File.expand_path('..',File.dirname(__FILE__)))
      end
      # @todo
      def log_path
        options[:log_path] || File.join(%w( #{base_dir} log serial.log ))
      end
      # @todo
      def pid_dir
        options[:pid_dir] || File.join(%w( #{base_dir} tmp pids ))
      end
    end

    # include Config
    # require 'ib_serial_server'
    # require 'ib_serial_msg'

    # START_BYTE = ">"
    # STOP_BYTE  = "\n"

    # # @private opcodes
    # ACCESS_REQUEST  = "01"
    # ACCESS_OK       = "02"
    # ACCESS_DENY     = "03"
    # NEWID_REQUEST   = "04"
    # NEWID_SET       = "05"
    # NEWID_ACCEPTED  = "06"
    # SET_PARAM       = "07"
    # RESET_ID        = "08"
    # SET_DEFAULT     = "09"
    # COM_ALIVE       = "0A"
    # UPG_REQUEST     = "10"
    # UPG_ACCEPTED    = "11"
    # UPG_DATA        = "12"
    # UPG_BLOCK_SYNC  = "13"
    # UPG_DATA_RESP   = "14"
    # UPG_FINISH      = "15"
    # UPG_FINISH_RESP = "16"

    # # Connect to serial port and read/handle messages.
    # # @param device
    # # @param baud_rate
    # # @return [Server] an instance of {Server} which is sub-class of
    # # {http://rubygems.org/gems/serialport SerialPort}
    # def self.server(device = SerialConfig.dev, baud_rate = SerialConfig.baud)
    #   ibs = Server.new(device, baud_rate)
    #   msg = ibs.gets
    #   if msg.length == 22
    #     ibs.handle(msg)
    #   end
    # end
  end
end

# run as standalone rb file
if __FILE__ == $0
  while true
    Ib::Serial.server
  end
end

