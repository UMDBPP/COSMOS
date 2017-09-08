# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the sequence counter field of a CCSDS packet
  class SeqcntProtocol < Protocol
  # @param seqcnt_byte_offset [Integer] The byte offset of the sequence counter field

    def initialize(seqcnt_byte_offset = 0)
      super()
      @seqcnt_byte_offset = Integer(seqcnt_byte_offset)
      @seqcnt_max_val
    end

    # Called to perform modifications on write data before making it into a packet
    #
    # @param data [String] Raw packet data
    # @return [String] Packet data with filled checksum
    def write_data(data)
      #put "this is a test" 

      # update the packet checksum
      data = update_ccsds_seqcnt(data)

      return super(data)
    end

    def update_ccsds_seqcnt(packet_data)

     # calculate the checksum
      seqcnt = @interface.write_count

      # ensure that the value doesn't overrun the 14 bits allocated to it
      # this will result in teh sequence counter wrapping
      seqcnt = seqcnt % 16383
    
      # debug statement
      puts "seqcnt 0x#{seqcnt.to_s(16)}"

      # get the bytes in that field and convert them back to an integer
      existing_val = packet_data[@seqcnt_byte_offset].unpack("C").last * 256 + packet_data[@seqcnt_byte_offset+1].unpack("C").last

      # or the values together
      new_val = existing_val | seqcnt

      packet_data[@seqcnt_byte_offset] = [(new_val & 0xFF00) >> 8].pack("C")
      packet_data[@seqcnt_byte_offset+1] =  [new_val & 0x00FF].pack("C")
    
      # return the data with the length field updated
      return packet_data
    end

  end
end
