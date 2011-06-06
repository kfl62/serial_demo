#encoding: utf-8
require 'serialport'
module Ib
  # #Ib:Serial module
  # ##Description:
  # One of three main modules of the application iButton ({Serial},{Db},{Web}),
  # responsible in principle for communication with serial port, but also for
  # updating the database and log files.
  # ##Scope:
  # @todo document this module
  module Serial
    # Just for raising/rescuing errors
    class SerialError < StandardError; end
    # Just for raising/rescuing errors
    class SerialHwError < SerialError; end
    # Just for raising/rescuing errors
    class SerialPermissionError < SerialError; end
    # start ASCII char for message
    START_BYTE = ">"
    # last ASCII char for message
    STOP_BYTE  = "\n"
    # opcode for get action request
    ACTION_REQUEST  = "01"
    # opcode for send action granted
    ACTION_OK       = "02"
    # opcode for send action denied
    ACTION_DENY     = "03"
    # opcode for get new sid request
    NEWID_REQUEST   = "04"
    # opcode for send new sid value
    NEWID_SET       = "05"
    # opcode for get accept response
    NEWID_ACCEPTED  = "06"
    # @todo
    SET_PARAM       = "07"
    # opcode for get button pressed message
    INSIDE_BUTTON   = "08"
    # @todo
    SET_DEFAULT     = "09"
    # @todo
    COM_ALIVE       = "0A"
    # @todo
    UPG_REQUEST     = "10"
    # @todo
    UPG_ACCEPTED    = "11"
    # @todo
    UPG_DATA        = "12"
    # @todo
    UPG_BLOCK_SYNC  = "13"
    # @todo
    UPG_DATA_RESP   = "14"
    # @todo
    UPG_FINISH      = "15"
    # @todo
    UPG_FINISH_RESP = "16"

    autoload :Daemon,   'serial/daemon'
    autoload :Server,   'serial/server'
    autoload :Telegram, 'serial/telegram'
    autoload :Upgrade,  'serial/upgrade'
  end
end
