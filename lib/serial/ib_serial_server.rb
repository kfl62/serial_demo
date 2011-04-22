#encoding: utf-8

module Ib
  module Serial
    # @todo document this class
    class Server < SerialPort
      include Db::Hw
      include Db::Persons

      def sid(msg)
        msg[2,2] + msg[0,2]
      end

      def opcode(msg)
        msg[4,2]
      end

      def reader_nr
        msg[6,2]
      end

      # TODO find out from where comes de device_id
      #def device_nr
        #msg[8,2]
      #end

      def key_id(msg)
        msg[8,12]
      end

      def acces_allow(ibs,s_id,key_id)
        STDOUT << Time.now.to_s + " " + "Access request on node: " + s_id + " key: " + key_id + "\n"
        if Key.find(:keyId => key_id)
          ibs.write(START_BYTE + sid(s_id) + ACCESS_OK + "010100" + ("%08d" % RESPONSEDATA) + STOP_BYTE)
          owner = Key.find(:keyId => key_id).owner.first_name
          retval = "Access granted on node: " + s_id + " for key: " + key_id + " (#{owner})\n"
        else
          ibs.write(START_BYTE + sid(s_id) + ACCESS_DENY + "01000000000000" + STOP_BYTE)
          retval = "Access denied on node: " + s_id + " for key: " + key_id + "\n"
        end
        STDOUT << Time.now.to_s + " " + retval
      end

      def handle(ibs,msg)
        msg = msg.slice(/[^>+].*[^\n+]/)
        case opcode(msg)
        when ACCESS_REQUEST
          acces_allow(ibs,sid(msg),key_id(msg))
        when COM_ALIVE
          retval = "Alive message from node: " + sid(msg) + "\n"
        else
          retval = "Unknown opcode (msg/opcode) " + msg +" / " + opcode(msg) + "\n"
        end
        STDOUT << Time.now.to_s + " " + retval if retval
      end

    end
  end
end

