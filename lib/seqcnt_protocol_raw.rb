# encoding: ascii-8bit

# Copyright Steve Lentine 2017
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3

require 'cosmos'
require 'cosmos/packets/binary_accessor'
require 'cosmos/interfaces/protocols/protocol'
require 'cosmos/config/config_parser'

module Cosmos
  # Protocol which fills the sequence counter bits of a CCSDS packet header
  # 
  #   example usage:
  #     PROTOCOL WRITE seqcnt_protocol.rb nil nil 19 14 6 11 BIG_ENDIAN
  class SeqcntProtocolRaw < Protocol
  # @param seqcnt_bit_offset [Integer] The bit offset of the sequence counter field (Default: 19)
  # @param seqcnt_bit_size [Integer] The size in bits of the sequence counter field (Default: 14)
  # @param apid_bit_offset [Integer] The bit offset of the ApID field (Default: 6)
  # @param apid_bit_size [Integer] The size in bits of the ApID field (Default: 11)
  # @param endianness [String] The endianness of the length field. Must be either BIG_ENDIAN or LITTLE_ENDIAN. (Default: BIG_ENDIAN)

    def initialize(
      seqcnt_bit_offset = 19, 
      seqcnt_bit_size = 14, 
      apid_bit_offset = 6, 
      apid_bit_size = 11,
      endianness = 'BIG_ENDIAN'
      )
      # the defaults set above will work for a CCSDS packet

      # convert arguments
      @seqcnt_bit_offset = Integer(seqcnt_bit_offset)
      @seqcnt_bit_size = Integer(seqcnt_bit_size)
      @apid_bit_offset = Integer(apid_bit_offset)
      @apid_bit_size = Integer(apid_bit_size)
      
      # Save endianness
      case endianness.to_s.upcase
        when 'BIG_ENDIAN'
          @endianness = :BIG_ENDIAN # Convert to symbol for use in BinaryAccessor.write
        when 'LITTLE_ENDIAN'
          @endianness = :LITTLE_ENDIAN # Convert to symbol for use in BinaryAccessor.write
        else
          raise "Invalid endianness '#{endianness}'. Must be BIG_ENDIAN or LITTLE_ENDIAN."
      end
      
      # create hashes to store the seqcnt for each APID
      @sent_seqcnts = {}; 
      @rcvd_seqcnts = {}; 
            
    end

    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled sequence counter
    def write_data(data)
      
      # read the APID from the packet
      apid = BinaryAccessor.read(@apid_bit_offset, 
                                 @apid_bit_size, 
                                 :UINT, 
                                 data, 
                                 @endianness)  
    
      # if the key does not yet exist in the hash (ie, this is the first time 
      #   this packet has been sent), add an entry to the hash
      if(@sent_seqcnts.key?(apid))
        @sent_seqcnts[apid] = 0
      
      # otherwise, increment the key that already exists
      else
        @sent_seqcnts[apid] += 1;
      end
    
      # use the value from the hash
      seqcnt = @sent_seqcnts[apid]
            
      # make sure the value will fit in the bits allocated for it
      #  wraps value if too large
      seqcnt = @sent_seqcnts[apid] % ( 2 ** @seqcnt_bit_size -1) 
      
      # write the APID into the packet
      BinaryAccessor.write(seqcnt, 
                           @seqcnt_bit_offset, 
                           @seqcnt_bit_size, 
                           :UINT,
                           data, 
                           @endianness, 
                           :ERROR)

      return data
    end
  end
end
