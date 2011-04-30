#! /usr/bin/env ruby
#encoding: utf-8

require './config/ib_config'
require './lib/ib_db'

module Ib
  # @todo document this module
  module Serial
    include Config
    require 'ib_serial_server'
    require 'ib_serial_msg'

    START_BYTE = ">"
    STOP_BYTE  = "\n"

    # @private opcodes
    ACCESS_REQUEST  = "01"
    ACCESS_OK       = "02"
    ACCESS_DENY     = "03"
    NEWID_REQUEST   = "04"
    NEWID_SET       = "05"
    NEWID_ACCEPTED  = "06"
    SET_PARAM       = "07"
    RESET_ID        = "08"
    SET_DEFAULT     = "09"
    COM_ALIVE       = "0A"
    UPG_REQUEST     = "10"
    UPG_ACCEPTED    = "11"
    UPG_DATA        = "12"
    UPG_BLOCK_SYNC  = "13"
    UPG_DATA_RESP   = "14"
    UPG_FINISH      = "15"
    UPG_FINISH_RESP = "16"

    # Connect to serial port and read/handle messages.
    # @param device
    # @param baud_rate
    # @return [Server] an instance of {Server} which is sub-class of {http://rubygems.org/gems/serialport SerialPort}
    def self.server(device = SerialConfig.dev, baud_rate = SerialConfig.baud)
      ibs = Server.new(device, baud_rate)
      msg = ibs.gets
      ibs.handle(msg)
    end
  end
end

# run as standalone rb file
if __FILE__ == $0
  while true
    Ib::Serial.server
  end
end

