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
            if msg[6,2] == '01'
              logger.warn("Alive message with last error: TASKREADKEYBLOCKED")
              Pony.mail(:to => Pony.options[:to],
                        :subject => "WARN: Alive with 01",
                        :body => "Alive message with last error: TASKREADKEYBLOCKED") if opt.mail
            end
            if msg[6,2] == '02'
              logger.warn("Alive message with last error: TASKREADKEYCONTOROVERFLOW")
              Pony.mail(:to => Pony.options[:to],
                        :subject => "WARN: Alive with 02",
                        :body => "Alive message with last error: TASKREADKEYCONTOROVERFLOW") if opt.mail
            end
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
            Pony.mail(:to => Pony.options[:to],
                      :subject => "WARN: Action request",
                      :body => "Action request ignored! Reason: #{e.message}") if opt.mail
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
            Pony.mail(:to => Pony.options[:to],
                      :subject => "WARN: NewID request",
                      :body => "NewID request ignored! Reason: #{e.message}") if opt.mail
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
            Pony.mail(:to => Pony.options[:to],
                      :subject => "WARN: Alive message",
                      :body => "Alive message ignored! Reason: #{e.message}") if opt.mail
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
          Pony.mail(:to => Pony.options[:to],
                    :subject => "WARN: Permissions",
                    :body => "Permission denied! Reason: #{e.message}") if opt.mail
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
        Pony.mail(:to => Pony.options[:to],
                  :subject => "WARN: New Key / Owner",
                  :body => "New key with keyId=#{keyId} was inserted in Key table\n" +
                           "New owner (Owner New) was created! Rename and associate with group!") if opt.mail
      end
      # @todo
      def db_add_status_node(node)
        logger.warn("Node with sid=#{node.sid} will be inserted in Status table!")
        Status.insert([nil,Time.now,node.id,node.name,Time.now])
        logger.info("Node sid=#{node.sid} is tracked for alive status...")
        Pony.mail(:to => Pony.options[:to],
                  :subject => "WARN: Node in Status",
                  :body => "Node with sid=#{node.sid} was inserted in Status table!") if opt.mail
      end
    end # Server
  end # Serial
end # Ib

