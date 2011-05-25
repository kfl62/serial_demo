#encoding: utf-8
require 'serialport'
module Ib
  # @todo document this module
  module Serial
    # @todo
    class SerialError < StandardError; end

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

    autoload :Daemon,   'serial/daemon'
    autoload :Server,   'serial/server'
  end
end


