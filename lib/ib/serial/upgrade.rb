#encoding: utf-8
module Ib
  module Serial
    # #Ib::Serial::Upgrade module
    # ##Description:
    # ##Scope:
    # @todo document this module
    module Upgrade
      # @todo
      class SerialUpgradeError < SerialError; end
      # @todo
      CCITT_16 = [
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
        0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
        0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
        0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
        0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
        0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
        0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
        0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
        0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
        0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
        0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
        0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
        0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
        0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
        0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
        0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
        0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
        0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
        0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
        0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
        0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
        0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
        0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
        0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
        0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
        0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
        0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
        0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
        0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
        0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
        0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
        0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
      ]
      # @todo
      BOOT_LOADER = 512...4096
      # @todo
      def crc16(buf, crc=0xFFFF)
        buf.scan(/../).each{|x| crc = ((crc & 0x00FF) << 8) ^ CCITT_16[((crc >> 8) ^ x.hex) & 0x00FF]}
        crc
      end
      # @todo
      def file_parse(file)
        begin
          file = File.join(Ib.app_root,'vendor','firmware',file)
          file_data = File.new(file,'r')
        rescue Errno::ENOENT => e
          Ib.logger.error("Upgrade failed: #{e.message}")
          return false
        else
          version = file[/_(.+)\./,1]
          upgrade_hash = data_blocks_build(file_data)
          upgrade_hash["version"] = version.length == 4 ? version : '0000'
          return upgrade_hash
        ensure
          file_data.close if file_data
        end
      end
      # @todo
      def data_blocks_build(stream,upgrade_hash = {})
        upgrade_hash["hex_data"] = Hash.new
        upgrade_hash["size"] = 0
        address, ext_address = 0, 0
        done = false
        begin
          line = stream.gets
          record_type = line[7,2]
          raise SerialUpgradeError, "recordType: 04" if record_type == "04"
          raise SerialUpgradeError, "recordType: XX" if record_type != "00"
        rescue SerialUpgradeError => e
          if record_type == "04"
            ext_address = line[9,4].hex << 16
            logger.warn("Upgrade recordType:04 ext_address updated: #{ext_address.to_s(16)}")
          else
            logger.error("Upgrade failed: Unknown recordType")
            done = true
            return false
          end
        else
          address = (line[3,4].hex + ext_address) / 2
          line.unpack("@9a16@25a16").each do |word|
            unless BOOT_LOADER.include?(address)
              block,packet = upgrade_hash["size"].divmod(1536)
              block   = "%02X" % block
              packet  = "%02X" % packet
              data = word.unpack("a2@2a2@4a2@8a2@10a2@12a2").pack("a2a2a2a2a2a2")
              if packet == "00"
                upgrade_hash["hex_data"][block] = [data]
              else
                upgrade_hash["hex_data"][block] << data
              end
              if (address > BOOT_LOADER.end && word =~ /\AFFFFFF00/)
                upgrade_hash["size"] += 6
                done = true
              end
              upgrade_hash["size"] += 6 unless done
            end
          end
        end until done
        logger.info("Hexfile parsed (Code size: #{upgrade_hash["size"]})")
        return upgrade_hash
      end
      # @todo
      def data_blocks_send
        @upgrade_hash["hex_data"].each_pair do |block, data_ary|
          block_send(block,data_ary)
          block_sync(block,data_ary)
          block_sync_check(block,data_ary)
        end
      end
      # @todo
      def block_send(block,data_ary)
        msg_helper = @upgrade_hash["c_sid"] == 2047 ? "broadcast" : "node"
        logger.info("Sending block: #{block} to #{msg_helper}: #{@upgrade_hash["c_sid"]}")
        data_ary.each_with_index do |line,index|
          data = ["%02X" % index, line]
          srv_handle_outgoing(UPG_DATA, data)
          sleep(0.01)
        end
      end
      # @todo
      def block_sync(block,data_ary)
        @upgrade_hash["c_crc"] = crc16(data_ary.join)
        logger.info("Block:#{block} was sent. Sending synchronization msg, crc:#{"%04X" % @upgrade_hash["c_crc"]}")
        data = [@upgrade_hash["c_crc"], block, data_ary.length]
        @upgrade_hash["sync_noresp"] = @upgrade_hash["nodes"] - @upgrade_hash["nodes_dead"]
        srv_handle_outgoing(UPG_BLOCK_SYNC,data)
        sleep(0.5)
      end
      # @todo
      def block_sync_check(block,data_ary)
        if @upgrade_hash["sync_noresp"].empty?
          if @upgrade_hash["sync_error"].empty?
            logger.info("Synchronization: Successful...")
          else
            block_sync_error(block,data_ary)
          end
        else
          block_sync_missing(block,data_ary)
          block_sync_check(block,data_ary)
        end
      end
      # @todo
      def block_sync_error(block,data_ary)
        logger.warn("Synchronization: Problem...")
        @upgrade_hash["sync_error"].each_pair do |sid,error|
          data_blocks_resend(sid,block,error)
        end
        logger.info("Data requested by node(s) in their UPG_DATA_RESP was sent.")
        logger.info("Clearing sync_error and sending synchronization msg. for implied!")
        @upgrade_hash["sync_error"].each_key do |sid|
          @upgrade_hash["c_sid"] = sid
          srv_handle_outgoing(UPG_BLOCK_SYNC,[@upgrade_hash["c_crc"],block,data_ary.length])
        end
        @upgrade_hash["c_sid"] = @upgrade_hash["b_sid"]
        @upgrade_hash["sync_error"].clear
        sleep(0.5)
        block_sync_check(block,data_ary)
      end
      # @todo
      def block_sync_missing(block,data_ary)
        while !@upgrade_hash["sync_noresp"].empty?
          if @upgrade_hash["sync_retry"] > 0
            logger.warn("No UPG_DATA_RESP from node(s) #{@upgrade_hash["sync_noresp"].join(', ')} !")
            @upgrade_hash["sync_noresp"].each do |sid|
              @upgrade_hash["c_sid"] = sid
              srv_handle_outgoing(UPG_BLOCK_SYNC,[@upgrade_hash["c_crc"],block,data_ary.length])
            end
            @upgrade_hash["sync_retry"] -= 1
            sleep(0.5)
          else
            @upgrade_hash["nodes_dead"] = @upgrade_hash["nodes_dead"] | @upgrade_hash["sync_noresp"]
            @upgrade_hash["sync_noresp"].clear
            @upgrade_hash["sync_retry"] = 3
            logger.warn("Synchronization msg sent 3 times to node(s) #{@upgrade_hash["nodes_dead"].join(', ')}")
            logger.warn("Presuming they were disconnected during upgrade!")
          end
        end
        @upgrade_hash["c_sid"] = @upgrade_hash["b_sid"]
      end
      # @todo
      def data_blocks_resend(sid,block,error)
        @upgrade_hash["c_sid"] = sid
        case error
        when nil
          logger.warn("Synchronization status:03 from node:#{sid}")
          logger.info("Sending again block: #{block} to node: #{sid}")
          @upgrade_hash["hex_data"][block].each_with_index do |line,index|
            data = ["%02X" % index, line]
            srv_handle_outgoing(UPG_DATA, data)
            sleep(0.01)
          end
        else
          logger.warn("Synchronization status:02 from node#{sid}")
          logger.info("Sending again line(s) with index: #{error.join(',')} to node: #{sid}")
          error.each do |e|
            line = @upgrade_hash["hex_data"][block][e.hex]
            srv_handle_outgoing(UPG_DATA, [e,line])
            sleep(0.01)
          end
        end
      end
      # @todo
      def data_blocks_finish
        logger.info("Upgrade was completed in #{Time.now - @upgrade_hash["start"]} seconds.")
        logger.info("Sending UPG_FINISH opcode to node/broadcast: #{@upgrade_hash["c_sid"]}.")
        if @upgrade_hash["nodes_dead"].empty?
          srv_handle_outgoing(UPG_FINISH,@upgrade_hash["c_sid"])
        else
          logger.warn "Node(s) #{@upgrade_hash["nodes_dead"].join(', ')} were disconnected during upgrade!"
          logger.warn "Sending upgrade finished only to alive node(s)..."
          (@upgrade_hash["nodes"] - @upgrade_hash["nodes_dead"]).each do |sid|
            @upgrade_hash["c_sid"] = sid
            srv_handle_outgoing(UPG_FINISH,@upgrade_hash["c_sid"])
          end
        end
        sleep(0.5)
        if (@upgrade_hash["nodes"] - @upgrade_hash["nodes_dead"]).empty?
          logger.info("Received upgrade completed responses from all implied node(s)...")
          logger.info("Clearing upgrade_hash...")
          @upgrade_hash.clear
        else
          logger.warn("No UPG_FINISH_RESP from node(s) sid:#{(@upgrade_hash["nodes"] - @upgrade_hash["nodes_dead"]).join(',')} !")
          logger.info("Waiting for 60 seconds and clearing upgrade_hash")
          sleep(60)
          @upgrade_hash.clear
        end
      end
    end # Upgrade
  end # Serial
end # Ib