#encoding: utf-8

module Ib
  module Serial
    # @todo document this module
    # @private module Msg{{{1
    module Msg
      include Db::Hw
      include Db::Persons
      include Db::Log

      extend self

      # @todo Document this method
      # @private def string_sid{{{2
      def string_sid(msg)
        if msg.class == Fixnum
          retval = "%04X" % msg
          retval= retval[2,2] + retval[0,2]
        else
         retval= msg[2,2] + msg[0,2]
         retval = retval.to_i(16)
        end
        retval
      end
      # @todo Document this method
      # @private def string_opcode{{{2
      def string_opcode(msg)
        msg[4,2]
      end
      # @private def string_reader{{{2
      # Readers ID part from ASCII message.
      #   Ex. msg[6,2] on access request.
      # @return [String] readers ID #=> "01"
      def string_reader(msg)
        retval = msg[6,2]
        retval = retval.to_i(16) if msg.class == String
        retval = "%02X" % msg if msg.class == Fixnum
        retval
      end
      # @todo Document this method
      # @private def string_device{{{2
      def string_device(msg)
        retval = msg[8,2]
        retval = retval.to_i(16) if msg.class == String
        retval = "%02X" % msg if msg.class == Fixnum
        retval
      end
      # @todo Document this method
      # @private def string_keyId {{{2
      def string_keyId(msg)
        msg[8,12]
      end
      # @todo
      # @private def msg_missing_hw_in_db{{{2
      def msg_missing_hw_in_db(m,msg)
        msg_node = m[0].nil? ? nil : "Node id=#{m[0]} not in DB (opcode '#{string_opcode(msg)}')"
        msg_reader = m[1].nil? ? nil : "Reader id=#{m[1]} not in DB (opcode '#{string_opcode(msg)}'"
        unless msg_node.nil?
          Error.create(:from => "Missing node", :error => msg_node)
          STDOUT << Time.now.to_s + " " + msg_node + "\n"
        end
        unless msg_reader.nil?
          Error.create(:from => "Missing reader", :error => msg_reader)
          STDOUT << Time.now.to_s + " " + msg_reader + "\n"
        end
      end
      # @todo Document this method
      # @private def msg_access_request{{{2
      def msg_access_request(m)
        k = Key[:keyId => string_keyId(m)]
        unless k.nil?
          msg = [nil,
                 Time.now,
                 k.owner.id.to_s,
                 k.owner.full_name,
                 Node[:sid => string_sid(m)].name,
                 Reader[:id => string_reader(m)].name,
                 "NDA",
                 "NDA",
                 "Access request",
                 false
                ]
        else
          new_key = Key.create(:keyId => string_keyId(m))
          new_owner = Owner.create(:first_name => "New", :last_name => "Owner")
          new_owner.add_key new_key
          new_owner.save
          msg = [nil,
                 Time.now,
                 new_owner.id.to_s,
                 new_owner.full_name,
                 Node[:sid => string_sid(m)].name,
                 Reader[:id => string_reader(m)].name,
                 "NDA",
                 "NDA",
                 "Access request",
                 false
                ]
           Error.create(:from => "Hw::Key id=#{new_key.id}",
                        :error => "Attention a new key was registered!")
           Error.create(:from => "Persons:Owner id=#{new_owner.id}",
                        :error => "A new owner with key=#{new_key.keyId} was created! Please rename and join group!")
        end
        #Access.insert(msg) # Commented out on Attila's request
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      # @private def msg_access_granted{{{2
      def msg_access_granted(m,p)
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               k.owner.id.to_s,
               k.owner.full_name,
               p.request_node.name,
               p.request_reader.name,
               p.response_node.name,
               p.response_device.name,
               "ACCESS_OK",
               true
              ]
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      # @private def msg_access_denied{{{2
      def msg_access_denied(m,e)
        error = Error.create(:from => "Hw::Node id=#{string_sid(m)}",
                             :error => "ACCESS_DENY reason: #{e.join(',')}"
                            )
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               k.owner.id.to_s,
               k.owner.full_name,
               Node[:sid => string_sid(m)].name,
               Reader[:id => string_reader(m)].name,
               "NDA",
               "NDA",
               "ACCESS_DENY",
               false
              ]
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      # @private def msg_com_alive{{{2
      def msg_com_alive(m)
        node_status = Status[:node_id => Node[:sid => string_sid(m)].id]
        if node_status.nil?
          msg = [nil,
                 Time.now,
                 Node[:sid => string_sid(m)].id,
                 Node[:sid => string_sid(m)].name,
                 Time.now
                ]
          Status.insert(msg)
          msg =  msg.compact.join(' | ')
          msg += " | Alive status record created!\n"
          STDOUT << msg
        else
          msg = [Time.now,
                 node_status.node_id,
                 node_status.node,
                 "Alive status updated!\n"
                ]
          node_status.save
          STDOUT << msg.join(' | ')
        end
      end
      # @todo Document this method
      # @private def msg_newid_request{{{2
      def msg_newid_request(m)
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               k.owner.id.to_s,
               k.owner.full_name,
               string_sid(m),
               string_reader(m),
               "NDA",
               "NDA",
               "NEWID_REQUEST",
               true
              ]
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      # @private def msg_newid_accepted{{{2
      def msg_newid_accepted(m)
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               "NDA",
               "Server",
               string_sid(m),
               string_reader(m),
               string_sid(m[10,4]),
               "NDA",
               "NEWID_ACCEPTED",
               true
              ]
        Node.insert(nil,
                    string_sid(m),
                    Time.now,
                    "New Node",
                    string_reader(m),
                    string_device(m),
                    Time.now,
                    Time.now
                   ) unless string_sid(m) == 2046
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      # @private def msg_unknown_opcode{{{2
      def msg_unknown_opcode(m)
        msg = [nil,
               Time.now,
               "NDA",
               "Node",
               string_sid(m),
               "NDA",
               "NDA",
               "NDA",
               "Unknown opcode '#{string_opcode(m)}'",
               false
              ]
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
    end # Msg
  end # Serial
end # Ib

