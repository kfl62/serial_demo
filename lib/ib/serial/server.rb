#encoding: utf-8

module Ib
  module Serial
    # @todo document this class
    class Server < SerialPort
      include Mixins, Telegram, Db::Hw, Db::Persons, Db::Log

      attr_accessor :request_node, :request_reader, :key, :owner, :groups, :permission
      # DB Models in which can be automatically insert new records
      def srv_auto_insert
        [Key,Status]
      end
      # Handle incoming commands/messages
      #
      # @todo more documentation
      def srv_handle_incoming(msg)
        msg = get_set_msg(msg)
        case get_set_opcode(msg)
        when ACTION_REQUEST
          srv_check_request(msg)
        when NEWID_REQUEST
          srv_check_request(msg)
        when NEWID_ACCEPTED
          db_msg_hw, db_msg_log, log_msg = tg_opcode_06(msg)
          unless get_set_sid(msg[0,4]) == 2046
            Node.insert(db_msg_hw)
            Access.insert(db_msg_log)
            logger.info(log_msg.join(','))
          end
        when INSIDE_BUTTON
          if srv_check_hw(tg_opcode_08(msg))
            logger.debug("Inside button pressed hw_check passed...")
            logger.info("Inside button pressed on node #{@request_node.name}!")
            Access.insert([nil,Time.now(),0,"Inside button",@request_node.name,"NDA","NDA","NDA","INSIDE_BUTTON",true])
          end
        when COM_ALIVE
          if srv_check_hw(tg_opcode_0A(msg))
            logger.debug("Alive message hw_check passed...")
            logger.debug("Alive message from #{@request_node.name} :data: #{msg[6,14]}")
            Status[:node_id => @request_node.id].save
          end
        else
          logger.error("Unknown/Unhandled opcode! (#{get_set_opcode(msg)})")
        end
      end
      # Handle outgoing commands/messages
      #
      # According to opcode call a {Telegram} instance method (tg_opcode_XX) and send
      # the return array values, which are [serial_msg,db_msg,log_msg], to appropriate
      # destination (serial-port, database, logger). Notice that this may be repetitive!
      def srv_handle_outgoing(opcode,msg)
        case opcode
        when ACTION_OK
          serial_msg, db_msg, log_msg = tg_opcode_02(msg)
          ibs.write get_set_msg(serial_msg)
          Access.insert(db_msg)
          logger.info(log_msg.join(','))
        when ACTION_DENY
          serial_msg, db_msg, log_msg = tg_opcode_03(msg)
          ibs.write get_set_msg(serial_msg)
          Access.insert(db_msg)
          logger.info(log_msg.join(','))
        when NEWID_SET
          for id in 1..2045
            if Node[:sid  => id.to_s].nil?
              new_sid = id
              break
            end
          end
          serial_msg, db_msg, log_msg = tg_opcode_04(msg,true)
          Access.insert(db_msg)
          logger.info(log_msg.join(','))
          serial_msg, db_msg, log_msg = tg_opcode_05(msg,new_sid)
          ibs.write get_set_msg(serial_msg)
          logger.info(log_msg.join(','))
        else
          #
        end
      end
      # @todo
      def srv_check_request(msg)
        case get_set_opcode(msg)
        when ACTION_REQUEST
          if srv_check_hw(tg_opcode_01(msg))
            logger.debug("Action request hw_check passed...")
            p = srv_check_permission(msg)
            if p.class == String
              srv_handle_outgoing(ACTION_DENY,p)
            else
              logger.debug("Action request permission_check passed...")
              srv_handle_outgoing(ACTION_OK,p)
            end
          end
        when NEWID_REQUEST
          if srv_check_hw(tg_opcode_04(msg))
            logger.debug("NewId request hw_check passed...")
            srv_handle_outgoing(NEWID_SET,msg)
          else
          end
        else
          logger.error("Should Not reach here! Check request: (#{msg})")
        end
      end
      # Check if hw mentioned in the message is registered in database
      # @raise SerialHwError
      def srv_check_hw(hw)
        case hw[0]
        when ACTION_REQUEST
          begin
            @request_node = Node[:sid => hw[1]]
            @request_reader = @request_node.by_reader_order(hw[2]) if @request_node
            @key = Key[:keyId => hw[3]]
            raise SerialHwError, "Node with sid=#{hw[1]} not registered in DB!" if @request_node.nil?
            raise SerialHwError, "Reader with order=#{hw[2]} not registered on Node with sid=#{hw[1]}!" if @request_reader.nil?
            raise SerialHwError, "Key with keyId=#{hw[3]} not registered in DB" if @key.nil?
          rescue SerialHwError => e
            logger.warn("Action request ignored! Reason: #{e.message}")
            if @key.nil? && srv_auto_insert.include?(Key)
              db_add_key_owner(hw[3])
            end
            false
          else
            true
          end
        when NEWID_REQUEST
          begin
            @request_node = hw[1]
            @request_reader = hw[2]
            @key = Key[:keyId => hw[3]]
            raise SerialHwError, "Unusual sid! #{@request_node} instead of 2046" if @request_node != 2046
            raise SerialHwError, "Key with keyId=#{hw[3]} not registered in DB" if @key.nil?
         rescue SerialHwError => e
            logger.warn("NewId request ignored! Reason: #{e.message}")
            false
          else
            true
          end
        when INSIDE_BUTTON
          begin
            @request_node = Node[:sid => hw[1]]
            raise SerialHwError, "Node with sid=#{hw[1]} not registered in DB!" if @request_node.nil?
          rescue SerialHwError => e
            logger.warn("Inside button ignored! Reason: #{e.message}")
            false
          else
            true
          end
        when COM_ALIVE
          begin
            @request_node = Node[:sid => hw[1]]
            @alive_status = Status[:node_id => @request_node.id] if @request_node
            raise SerialHwError, "Node with sid=#{hw[1]} not registered in DB!" if @request_node.nil?
            raise SerialHwError, "Node with sid=#{hw[1]}! is not tracked in Status table!" if @alive_status.nil?
          rescue SerialHwError => e
            logger.warn("Alive message ignored! Reason: #{e.message}")
            if @alive_status.nil? && srv_auto_insert.include?(Status)
              db_add_status_node(@request_node) unless @request_node.nil?
            end
            false
          else
            true
          end
        else
          logger.error("Should Not reach here! Check hw: (#{hw.join(',')})")
        end
      end
      # Check if request has appropriate permissions
      #
      # @todo Describe the intersection (Arrays of Objects)
      # Unfortunately we must handle the special case of requests form web interface!
      # @raise SerialPermissionError
      def srv_check_permission(msg)
        begin
          permission = []
          @groups = @key.owner.groups
          @groups.each do |group|
            permission << (group.permissions  & @request_node.request_permissions & @request_reader.permissions)
          end
          raise SerialPermissionError, "Group membership error!" if @groups.empty?
          raise SerialPermissionError, "Request node without permissions!" if @request_node.request_permissions.empty?
          raise SerialPermissionError, "Request reader without permissions!" if @request_reader.permissions.empty?
          raise SerialPermissionError, "No permission!" if permission.flatten.empty?
        rescue SerialPermissionError => e
          return e.message
          logger.warn e
        else
          @permission = permission.flatten.first
        end
      end
      # @todo
      def db_add_key_owner(keyId)
        logger.warn("Key with keyId=#{keyId} will be added to DB!")
        new_key = Key.create(:keyId => keyId)
        new_owner = Owner.create(:first_name => "New",:last_name => "Owner")
        new_owner.add_ib_key new_key
        new_owner.save
        logger.warn("New key with keyId=#{keyId} was inserted in Key table")
        logger.warn("New owner (Owner New) was created! Rename and associate with group!")
      end
      def db_add_status_node(node)
        logger.warn("Node with sid=#{node.sid} will be inserted in Status table!")
        Status.insert([nil,Time.now,node.id,node.name,Time.now])
        logger.info("Node sid=#{node.sid} is tracked for alive status...")
      end
      # # @todo Document this method
      # def handle(msg)
      #   msg = msg_prepare(msg)
      #   #missing = check_missing_hw_in_db(msg)
      #   #if missing.compact.empty?
      #     case get_set_opcode(msg)
      #     when ACTION_REQUEST
      #       acTION_request(msg)
      #     when COM_ALIVE
      #       Msg.msg_com_alive(msg)
      #     when NEWID_REQUEST
      #       newid_request(msg)
      #     when NEWID_ACCEPTED
      #       Msg.msg_newid_accepted(msg)
      #     else
      #       Msg.msg_unknown_opcode(msg)
      #     end
      #   #else
      #     #Msg.msg_missing_hw_in_db(missing,msg)
      #   #end
      # end
      # # @todo Document this method
      # def check_missing_hw_in_db(msg)
      #   opcode = Msg.string_opcode(msg)
      #   missing_node = Node[:sid => Msg.string_sid(msg)].nil? ? Msg.string_sid(msg) : nil
      #   missing_reader = Reader[:id => Msg.string_reader(msg)].nil? ? Msg.string_reader(msg) : nil
      #   case opcode
      #   when ACTION_REQUEST
      #     missing = [missing_node, missing_reader]
      #   when NEWID_REQUEST, NEWID_ACCEPTED
      #     missing = [nil, nil]
      #   else
      #     missing = [missing_node, nil]
      #   end
      #   missing
      # end
      # # @todo Document this method
      # def acTION_request(msg)
      #   msg_acTION_request(msg)
      #   access_response(msg)
      # end
      # # @todo Document this method
      # def access_response(msg)
      #   permission, error = check_permission(msg)
      #   permission = permission.flatten
      #   error = error.compact
      #   if error.empty?
      #     p = permission[0]
      #     write(START_BYTE + p.msg_response_node_sid + ACTION_OK + p.msg_request_reader_order + p.msg_response_device_order + "00" +  p.msg_response_device_taskId + STOP_BYTE)
      #     Msg.msg_access_granted(msg,p)
      #   else
      #     write(START_BYTE + msg[0,4] + ACTION_DENY + "01000000000000" + STOP_BYTE)
      #     Msg.msg_access_denied(msg,error)
      #   end
      # end
      # # @todo Document this method
      # def check_permission(msg)
      #   permission = []
      #   group = Key[:keyId => Msg.string_keyId(msg)].owner.groups
      #   node = Node[:sid => Msg.string_sid(msg)]
      #   reader = node.readers_dataset.filter(:order => Msg.string_reader(msg)).first
      #   group.each{|g| permission << (g.permissions & node.request_permissions & reader.permissions)}
      #   error_permission = permission.flatten.empty? ? "No permission!" : nil
      #   error_group =  group.empty? ? "Group membership error!" : nil
      #   error_node = node.request_permissions.empty? ? "Request node without permissions!" : nil
      #   error_reader = reader.permissions.empty? ? "Request reader without permissions!" : nil
      #   [permission, [error_permission,error_group,error_node,error_reader]]
      # end
      # # @todo Document this method
      # def newid_request(msg)
      #   write(START_BYTE + Msg.string_sid(2046) + NEWID_SET + msg[6,2] + Msg.string_sid(new_sid) + "00000000" + STOP_BYTE)
      #   Msg.msg_newid_request(msg)
      # end
    end # Server
  end # Serial
end # Ib

