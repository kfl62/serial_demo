#encoding: utf-8
module Ib
  module Serial
    # #Ib::Db::Serial::Telegram module
    # ##Description
    # ##Scope
    # The 22 character length ASCII string
    # START_BYTE ">", STOP_BYTE "\n"
    # @todo document this module
    module Telegram
      # ACTION_REQUEST
      #
      #     "> xxxx xx xx xxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         request_node_sid      0100 (MSB first 'bigendian')
      #         6,2         opcode                01
      #         8,2         request_reader_order  01
      #        10,12        keyId                 123456789ABC
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_01(msg)
        request_node_sid = get_set_sid(msg[0,4])
        opcode = get_set_opcode(msg[4,2])
        request_reader_order = get_set_reader(msg[6,2])
        keyId = get_set_key(msg[8,12])
        [opcode,request_node_sid,request_reader_order,keyId]
      end
      # ACTION_OK
      #
      #     "> xxxx xx xx xx 00 xxxxxxxx \n"
      #     Start/Length      Name                  Value/Example
      #         1,1         START_BYTE              >
      #         2,4         response_node_sid       0100 (MSB first 'bigendian')
      #         6,2         opcode                  02
      #         8,2         request_reader_order    01
      #        10,2         reesponse_device_order  01
      #        12,2         reserved                00
      #        14,8         response_device_taskID  00000001
      #        22,1         STOP_BYTE               \n
      #      # Note: START_BYTE, STOP_BYTE are added after this method
      # @return [Array]
      def tg_opcode_02(data)
        [
          [data.msg_response_node_sid,ACTION_OK,data.msg_request_reader_order,data.msg_response_device_order,"00",data.msg_response_device_taskId],
          [nil,Time.now,ibs.key.owner.id.to_s,ibs.key.owner.full_name,data.request_node.name,data.request_reader.name,data.response_node.name,data.response_device.name,"ACCESS_OK",true],
          ["ACTION GRANTED for",ibs.key.owner.id.to_s,ibs.key.owner.full_name,data.request_node.name,data.request_reader.name,data.response_node.name,data.response_device.name,data.response_device.task.name]
        ]
      end
      # ACTION_DENY
      #
      #     "> xxxx xx xx 000000000000 \n"
      #     Start/Length      Name                  Value/Example
      #         1,1         START_BYTE              >
      #         2,4         request_node_sid        0100 (MSB first 'bigendian')
      #         6,2         opcode                  03
      #         8,2         request_reader_order    01
      #        10,12        placeholder             000000000000
      #        22,1         STOP_BYTE               \n
      #      # Note: START_BYTE, STOP_BYTE are added after this method
      # @return [Array]
      def tg_opcode_03(data)
        [
          [ibs.request_node.sid,ACTION_DENY,ibs.request_reader.order,"000000000000"],
          [nil,Time.now,ibs.key.owner.id.to_s,ibs.key.owner.full_name,ibs.request_node.name,ibs.request_reader.name,"NDA","NDA","ACCESS_DENY",false],
          ["ACTION DENIED for",ibs.key.owner.full_name,ibs.request_node.name,ibs.request_reader.name,"Reason: #{data}"]
        ]
      end
      # NEWID_REQUEST
      #
      #     "> xxxx xx xx xxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         request_node_sid      0100 (MSB first 'bigendian')
      #         6,2         opcode                04
      #         8,2         request_reader_order  01
      #        10,12        keyId                 123456789ABC
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      #      # Special case! ibs.request_[node|reader] are string values not Objects
      # @return [Array]
      def tg_opcode_04(msg,out = false)
        unless out
          request_node_sid = get_set_sid(msg[0,4])
          opcode = get_set_opcode(msg[4,2])
          request_reader_order = get_set_reader(msg[6,2])
          keyId = get_set_key(msg[8,12])
          return [opcode,request_node_sid,request_reader_order,keyId]
        else
          return [
            [nil],
            [nil,Time.now,ibs.key.owner.id.to_s,ibs.key.owner.full_name,ibs.request_node,ibs.request_reader,"NDA","NDA","NEWID_REQUEST",true],
            [ibs.key.owner.id.to_s,ibs.key.owner.full_name,ibs.request_node,ibs.request_reader,"NDA","NDA","NEWID_REQUEST"]
          ]
        end
      end
      # NEWID_SET
      #
      #     "> xxxx xx xx xxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         request_node_sid      FE07 (MSB first 'bigendian',2046)
      #         6,2         opcode                05
      #         8,2         request_reader_order  01
      #        10,4         new_sid               0100 (MSB first 'bigendian')
      #        14,8         placeholder           00000000
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      #      # Special case! ibs.request_[node|reader] are string values not Objects
      # @return [Array]
      def tg_opcode_05(msg,new_id = 2046)
        [
          [get_set_sid(ibs.request_node),NEWID_SET,get_set_reader(ibs.request_reader),get_set_sid(new_id),"00000000"],
          [nil],
          ["A NEWID_SET command sent to Node (sid=#{ibs.request_node}), new sid=#{new_id}"]
        ]
      end
      # NEWID_ACCEPTED
      #
      #     "> xxxx xx xx xx xxxx xxxxxx \n"
      #     Start/Length      Name                  Value/Example
      #         1,1         START_BYTE              >
      #         2,4         request_node_sid        0100 (MSB first 'bigendian')
      #         6,2         opcode                  06
      #         8,2         request_node_readers_nr 01
      #        10,2         request_node_devices_nr 01
      #        12,4         old_sid                 FE07 (MSB first 'bigendian',2046)
      #        16,6         unknown data :(         xxxxxx
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @return [Array]
      def tg_opcode_06(msg)
        [
          [nil,get_set_sid(msg[0,4]),Time.now,"New node",get_set_reader(msg[6,2]),get_set_device(msg[8,2]),Time.now,Time.now],
          [nil,Time.now,0,"Serial server",get_set_sid(msg[0,4]),"NDA",get_set_sid(msg[10,4]),"NDA","NEWID_ACCEPTED",true],
          ["New node name=New Node,sid=#{get_set_sid(msg[0,4])},old_sid=#{get_set_sid(msg[10,4])},readers_nr=#{get_set_reader(msg[6,2])},devices_nr=#{get_set_device(msg[8,2])} inserted/updated in DB"]
        ]
      end
      # INSIDE_BUTTON
      #
      #     "> xxxx xx xxxxxxxxxxxxxx \n"
      #     Start/Length      Name                  Value/Example
      #         1,1         START_BYTE              >
      #         2,4         request_node_sid        0100 (MSB first 'bigendian')
      #         6,2         opcode                  08
      #         8,14        unknown data            00000000000000
      #        22,1         STOP_BYTE               \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @return [Array]
      def tg_opcode_08(msg)
        request_node_sid = get_set_sid(msg[0,4])
        opcode = get_set_opcode(msg[4,2])
        [opcode, request_node_sid]
      end
      # COM_ALIVE
      #
      #     "> xxxx xx xxxxxxxxxxxxxx \n"
      #     Start/Length      Name                  Value/Example
      #         1,1         START_BYTE              >
      #         2,4         request_node_sid        0100 (MSB first 'bigendian')
      #         6,2         opcode                  0A
      #         8,2         last_error              01|02 TASKREADKEY's status
      #        10,12        unknown data            000000000000
      #        22,1         STOP_BYTE               \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @return [Array]
      def tg_opcode_0A(msg)
        request_node_sid = get_set_sid(msg[0,4])
        opcode = get_set_opcode(msg[4,2])
        last_error = msg[6,2]
        [opcode, request_node_sid,last_error]
      end
      # UPG_REQUEST
      #
      #     "> xxxx xx xxxx xxxx xxxx xx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         broadcast_sid         FF07 (2047 MSB first 'bigendian')
      #         6,2         opcode                10
      #         8,4         upgrade_mode          0100 (0001 force 'bigendian')
      #                                           0000 (0000 normal'bigendian')
      #        12,4         fw_version            0100 (1.0 'bigendian')
      #        16,4         fw_size               6C60 (24648 'bigendian')
      #        20,2         reserved              B7 ??? why this value ???
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are added after this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_10(msg)
        broadcast_sid = get_set_sid(@upgrade_hash["b_sid"])
        upgrade_mode  = @upgrade_hash["forced"] ? get_set_endian('0001') : '0000'
        fw_version    = get_set_endian(@upgrade_hash["version"])
        fw_size       = get_set_endian("%04X" % @upgrade_hash["size"])
        reserved      = 'B7'
        [
          [broadcast_sid, UPG_REQUEST, upgrade_mode, fw_version, fw_size, reserved],
          [broadcast_sid, UPG_REQUEST, upgrade_mode, fw_version, fw_size, reserved],
          [broadcast_sid, UPG_REQUEST, upgrade_mode, fw_version, fw_size, reserved]
        ]
      end
      # UPG_ACCEPTED
      #
      #     "> xxxx xx xxxxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         accept_node_sid       0100 (MSB first 'bigendian')
      #         6,2         opcode                11
      #         8,14        reserved              00000000000000
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_11(msg)
        "Upgrade request accepted node sid:#{get_set_sid(msg[0,4])}"
      end
      # UPG_DATA
      #
      #     "> xxxx xx xx xxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         broadcast_sid         FF07 (2047 MSB first 'bigendian')
      #         6,2         opcode                12
      #         8,2         data_index_in_block   00-FF (from Upgrade#data_blocks_build)
      #         8,12        data                  xxxxxxxxxxxx (from Upgrade#data_blocks_build)
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_12(msg)
        broadcast_sid       = get_set_sid(@upgrade_hash["c_sid"])
        data_index_in_block = msg[0]
        data                = msg[1]
        [
          [broadcast_sid,UPG_DATA,data_index_in_block,data],
          [broadcast_sid,UPG_DATA,data_index_in_block,data],
          [broadcast_sid,UPG_DATA,data_index_in_block,data]
        ]
      end
      # UPG_BLOCK_SYNC
      #
      #     "> xxxx xx xxxx xxxx xxxx xx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         broadcast_sid         FF07 (2047 MSB first 'bigendian')
      #         6,2         opcode                13
      #         8,4         crc                   0FED (ED0F MSB first 'bigendian')
      #        12,4         block_index           0100 (0001 MSB first 'bigendian')
      #        16,4         block_size            0001 (0100 256 MSB first 'bigendian')
      #        20,2         reserved              B5 ??? why this value ???
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are added after this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_13(msg)
        broadcast_sid = get_set_sid(@upgrade_hash["c_sid"])
        crc           = get_set_endian("%04X" % msg[0])
        block_index   = msg[1] + "00"
        block_size    = get_set_endian("%04X" % msg[2])
        reserved      = "B5"
        [
          [broadcast_sid,UPG_BLOCK_SYNC,crc,block_index,block_size,reserved],
          [broadcast_sid,UPG_BLOCK_SYNC,crc,block_index,block_size,reserved],
          [broadcast_sid,UPG_BLOCK_SYNC,crc,block_index,block_size,reserved]
        ]
      end
      # UPG_DATA_RESP
      #
      #     "> xxxx xx xx xxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         updated_sid           0100 (0001 MSB first 'bigendian')
      #         6,2         opcode                14
      #         8,2         sync_status           01 OK, 02 failures <= 6, 03 resend block
      #        10,12        failed_pckg           6 * XX index of package in block
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_14(msg)
        updated_sid = get_set_sid(msg[0,4])
        sync_status = msg[6,2]
        failed_pckg = get_set_failed(msg[8,12])
        case sync_status
        when "01"
          [updated_sid, sync_status, nil]
        when "02"
          [updated_sid, sync_status, failed_pckg]
        when "03"
          [updated_sid, sync_status, nil]
        else
          # No chance to get here :)
        end
      end
      # UPG_FINISH
      #
      #     "> xxxx xx xxxxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         broadcast_sid         FF07 (2047 MSB first 'bigendian')
      #         6,2         opcode                15
      #         8,14        reserved              00000000000000 ??? garbage ???
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_15(msg)
        broadcast_sid = get_set_sid(@upgrade_hash['c_sid'])
        reserved = '00000000000000'
        [
          [broadcast_sid,UPG_FINISH,reserved],
          [broadcast_sid,UPG_FINISH,reserved],
          [broadcast_sid,UPG_FINISH,reserved]
        ]
      end
      # UPG_FINISH_RESP
      #
      #     "> xxxxxxxxxxxxxxxxxxxx \n"
      #     Start/Length      Name                Value/Example
      #         1,1         START_BYTE            >
      #         2,4         updated_sid           0100 (0001 MSB first 'bigendian')
      #         6,2         opcode                16
      #         8,14        reserved              00000000000000 ??? garbage ???
      #        22,1         STOP_BYTE             \n
      #      # Note: START_BYTE, STOP_BYTE are removed before this method
      # @param [String] msg
      # @return [Array]
      def tg_opcode_16(msg)
        updated_sid = get_set_sid(msg[0,4])
        [
          updated_sid,
          "Upgrade completed response from node sid:#{updated_sid}"
        ]
      end
      # Depending on the context, delete or add the START_BYTE and STOP_BYTE
      # @param [String] msg
      # @return [String]
      def get_set_msg(msg)
        msg.class == String ? msg.slice(/[^>+].*[^\n+]/) : [">",msg.join,"\n"].join
      end
      # According to params type, returns sid formatted as String or as Integer
      def get_set_sid(msg)
        if msg.class == Fixnum
          ("%04X" % msg).unpack("@2a2@0a2").pack("a2a2")
        else
          msg.unpack("@2a2@0a2").pack("a2a2").hex
        end
      end
      # @todo Document this method
      def get_set_opcode(msg)
        msg.length == 20 ? msg[4,2] : msg
      end
      # According to params type, returns reader or device order formatted as
      # String or as Integer.
      # @return [String, Integer] readers.order #=> "01"
      def get_set_reader(msg)
        retval = msg.to_i(16) if msg.class == String
        retval = "%02X" % msg if msg.class == Fixnum
        retval
      end
      alias get_set_device get_set_reader
      #
      # @todo Document this method
      def get_set_key(msg)
        msg.length == 20 ? msg[8,12] : msg
      end
      #
      # @todo
      def get_set_endian(msg)
        msg.unpack("@2a2@0a2").pack("a2a2")
      end
      # @todo
      def get_set_failed(msg, retval = [])
        ary = msg.scan(/../)
        for i in 0..ary.length - 1
          if ary[i] == '00'
            if i == 0
              retval << ary[i]
            else
              break
            end
          else
            retval << ary[i]
          end
        end
        retval
      end
    end
  end
end