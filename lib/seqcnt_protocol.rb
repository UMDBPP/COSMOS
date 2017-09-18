# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the sequence counter field of a CCSDS packet
  class SeqcntProtocol < Protocol
  # @param field_name [String] The name of the packet field to fill

    def initialize(field_name = "CCSDSSEQCNT")
      super()
      @field_name = field_name
    end


    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled sequence counter
    def write_packet(packet)

      field_bit_size = packet.get_item(@field_name).bit_size

      # if the value is too large for the field, it will error, so automatically
      # wrap the value
      seqcnt = @interface.write_count % ( 2 ** field_bit_size -1) 

      # write the value into the packet
      packet.write(@field_name, seqcnt)

      return super(packet)
    end

    # Called to perform modifications on data before it is written to the interface
    # Does nothing but calls the superclass method
    #
    # @param data [String] Raw packet data
    # @return [String] Packet data with filled checksum
    def write_data(data)

      return super(data)
    end



  end
end
