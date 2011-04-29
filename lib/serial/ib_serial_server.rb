#encoding: utf-8

module Ib
  module Serial
    # @todo document this class
    class Server < SerialPort
      include Db::Hw
      include Db::Persons
      include Db::Log

      # @todo Document this method
      def handle(msg)
        msg = msg.slice(/[^>+].*[^\n+]/)
        case Msg.string_opcode(msg)
        when ACCESS_REQUEST
          access_request(msg)
        when COM_ALIVE
          Msg.msg_com_alive(msg)
          #retval = "Alive message from node: " + Msg.string_sid(msg) + "\n"
        else
          Msg.msg_unknown_opcode(msg)
        end
        nil
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
          write(START_BYTE + p.msg_response_node_sid + ACCESS_OK + p.msg_request_reader_id + p.msg_response_device_id + "00" +  p.msg_response_device_taskId + STOP_BYTE)
          Msg.msg_access_granted(msg,p)
        else
          write(START_BYTE + Msg.string_sid(msg) + ACCESS_DENY + "01000000000000" + STOP_BYTE)
          Msg.msg_access_denied(msg,error)
        end
      end
      # @todo Document this method
      def check_permission(msg)
        permission = []
        group = Key[:keyId => Msg.string_keyId(msg)].owner.groups
        node = Node[:sid => Msg.string_sid(msg).to_i].request_permissions
        reader = Reader[:id => Msg.string_reader(msg).to_i].permissions
        group.each{|g| permission << (g.permissions & node & reader)}
        error_group =  group.empty? ? "Group membership error!" : nil
        error_node = node.empty? ? "Request node has no permission defined!" : nil
        error_reader = reader.empty? ? "Request reader has no permission defined!" : nil
        [permission, [error_group,error_node,error_reader]]
      end

    end # Server
  end # Serial
end # Ib

