#encoding: utf-8

module Ib
  module Serial
    # @todo document this class
    class Server < SerialPort
      include Utils
      include Ib::Db::Hw
      include Ib::Db::Persons
      include Ib::Db::Log

      # @todo Document this method
      def handle(msg)
        msg = msg.slice(/[^>+].*[^\n+]/)
        missing = check_missing_hw_in_db(msg)
        if missing.compact.empty?
          case Msg.string_opcode(msg)
          when ACCESS_REQUEST
            access_request(msg)
          when COM_ALIVE
            Msg.msg_com_alive(msg)
          when NEWID_REQUEST
            newid_request(msg)
          when NEWID_ACCEPTED
            Msg.msg_newid_accepted(msg)
          else
            Msg.msg_unknown_opcode(msg)
          end
        else
          Msg.msg_missing_hw_in_db(missing,msg)
        end
      end
      # @todo Document this method
      def check_missing_hw_in_db(msg)
        opcode = Msg.string_opcode(msg)
        missing_node = Node[:sid => Msg.string_sid(msg)].nil? ? Msg.string_sid(msg) : nil
        missing_reader = Reader[:id => Msg.string_reader(msg)].nil? ? Msg.string_reader(msg) : nil
        case opcode
        when ACCESS_REQUEST
          missing = [missing_node, missing_reader]
        when NEWID_REQUEST, NEWID_ACCEPTED
          missing = [nil, nil]
        else
          missing = [missing_node, nil]
        end
        missing
      end
      # @todo Document this method
      def access_request(msg)
        Msg.msg_access_request(msg)
        access_response(msg)
      end
      # @todo Document this method
      def access_response(msg)
        permission, error = check_permission(msg)
        permission = permission.flatten
        error = error.compact
        if error.empty?
          p = permission[0]
          write(START_BYTE + p.msg_response_node_sid + ACCESS_OK + p.msg_request_reader_order + p.msg_response_device_order + "00" +  p.msg_response_device_taskId + STOP_BYTE)
          Msg.msg_access_granted(msg,p)
        else
          write(START_BYTE + msg[0,4] + ACCESS_DENY + "01000000000000" + STOP_BYTE)
          Msg.msg_access_denied(msg,error)
        end
      end
      # @todo Document this method
      def check_permission(msg)
        permission = []
        group = Key[:keyId => Msg.string_keyId(msg)].owner.groups
        node = Node[:sid => Msg.string_sid(msg)]
        reader = node.readers_dataset.filter(:order => Msg.string_reader(msg)).first
        group.each{|g| permission << (g.permissions & node.request_permissions & reader.permissions)}
        error_permission = permission.flatten.empty? ? "No permission!" : nil
        error_group =  group.empty? ? "Group membership error!" : nil
        error_node = node.request_permissions.empty? ? "Request node without permissions!" : nil
        error_reader = reader.permissions.empty? ? "Request reader without permissions!" : nil
        [permission, [error_permission,error_group,error_node,error_reader]]
      end
      # @todo Document this method
      def newid_request(msg)
        for id in 1..2045
          if Node[:sid  => id.to_s].nil?
            new_sid = id
            break
          end
        end
        write(START_BYTE + Msg.string_sid(2046) + NEWID_SET + msg[6,2] + Msg.string_sid(new_sid) + "00000000" + STOP_BYTE)
        Msg.msg_newid_request(msg)
      end
    end # Server
  end # Serial
end # Ib

