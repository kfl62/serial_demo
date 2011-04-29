#encoding: utf-8

module Ib
  module Serial
    # @todo document this module
    module Msg
      include Db::Hw
      include Db::Persons
      include Db::Log

      extend self

      # @todo Document this method
      def string_sid(msg)
        msg[2,2] + msg[0,2]
      end
      # @todo Document this method
      def string_opcode(msg)
        msg[4,2]
      end
      # @todo Document this method
      def string_reader(msg)
        msg[6,2]
      end
      # @todo Document this method
      def string_keyId(msg)
        msg[8,12]
      end
      # @todo Document this method
      def msg_access_request(m)
        k = Key[:keyId => string_keyId(m)]
        unless k.nil?
          msg = [nil,
                 Time.now,
                 k.owner.id.to_s,
                 k.owner.full_name,
                 Node[:sid => string_sid(m).to_i].name,
                 Reader[:id => string_reader(m).to_i].name,
                 "NDA",
                 "Access request",
                 false
                ]
        else
          new_key = Key.create(:keyId => string_keyId(m))
          new_owner = Owner.create(:first_name => "New", :last_name => "Owner")
          new_owner.key= new_key
          new_owner.save
          msg = [nil,
                 Time.now,
                 new_owner.id.to_s,
                 new_owner.full_name,
                 Node[:sid => string_sid(m).to_i].name,
                 Reader[:id => string_reader(m).to_i].name,
                 "NDA",
                 "Access request",
                 false
                ]
           Error.create(:from => "Hw::Key id=#{new_key.id}",
                        :error => "Attention a new key was registered!")
           Error.create(:from => "Persons:Owner id=#{new_owner.id}",
                        :error => "A new owner with key=#{new_key.keyId} was created! Please rename and join group!")
        end
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      def msg_access_granted(m,p)
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               k.owner.id.to_s,
               k.owner.full_name,
               p.request_node.name,
               p.request_reader.name,
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
      def msg_access_denied(m,e)
        error = Error.create(:from => "Hw::Node id=#{string_sid(m)}",
                             :error => "ACCESS_DENY reason: #{e.join(',')}"
                            )
        k = Key[:keyId => string_keyId(m)]
        msg = [nil,
               Time.now,
               k.owner.id.to_s,
               k.owner.full_name,
               Node[:sid => string_sid(m).to_i].name,
               Reader[:id => string_reader(m).to_i].name,
               "NDA",
               "ACCESS_DENY (Error.id=#{error.id})",
               false
              ]
        Access.insert(msg)
        msg =  msg.compact.join(' | ')
        msg += "\n"
        STDOUT << msg
      end
      # @todo Document this method
      def msg_com_alive(m)
        node_status = Status[:node_id => Node[:sid => string_sid(m).to_i].id]
        if node_status.nil?
          msg = [nil,
                 Time.now,
                 Node[:sid => string_sid(m).to_i].id,
                 Node[:sid => string_sid(m).to_i].name,
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
      def msg_unknown_opcode(m)
        #retval = "Unknown opcode (msg/opcode) " + msg +" / " + Msg.string_opcode(msg) + "\n"
      end
    end # Msg
  end # Serial
end # Ib

