# encoding: ascii-8bit

# Copyright Steve Lentine 2017
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'
require 'cosmos/config/config_parser'

module Cosmos
  # Protocol which fills the sequence counter field of a CCSDS packet and/or
  # checks incoming packets for non-incrementing counter values
  # 
  #   example usage:
  #     PROTOCOL WRITE seqcnt_protocol.rb "CCSDSSEQCNT" "CCSDSAPID"
  class SeqcntProtocol < Protocol
  # @param seqcnt_item_name [String] The name of the sequence counter field (Optional: nil if using bit offset/size arguments, Default: CCSDSSEQCNT)
  # @param apid_item_name [String] The name of the ApID field (Optional: nil if using bit offset/size arguments, Default: CCSDSAPID)

    def initialize(seqcnt_item_name = "CCSDSSEQCNT", apid_item_name = "CCSDSAPID")

      # convert arguments
      @seqcnt_item_name = seqcnt_item_name.to_s
      @apid_item_name = apid_item_name.to_s
      
      # create hashes to store the seqcnt for each APID
      @sent_seqcnts = {}; 
      @rcvd_seqcnts = {}; 
            
    end

    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled sequence counter
    def write_packet(packet)

      # read the APID from the packet
      apid = packet.read(@apid_item_name)

      # if the key does not yet exist in the hash (ie, this is the first time 
      #   this packet has been sent), add an entry to the hash
      if(!@sent_seqcnts.key?(apid))
        @sent_seqcnts[apid] = 0

      # otherwise, increment the key that already exists
      else

        @sent_seqcnts[apid] += 1;
      end

      # get the size of the field
      seqcnt_bit_size = packet.get_item(@seqcnt_item_name).bit_size

      # make sure the value will fit in the bits allocated for it
      #  wraps value if too large
      seqcnt = @sent_seqcnts[apid] % ( 2 ** seqcnt_bit_size -1) 

      # write the seqcnt into the packet
      apid = packet.write(@seqcnt_item_name,seqcnt)

      return packet
    end 
  end
end
