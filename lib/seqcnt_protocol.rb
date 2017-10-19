# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the sequence counter field of a CCSDS packet
  class SeqcntProtocol < Protocol
  # @param field_name [String] The name of the packet field to fill

    def initialize(write_loc = "CCSDSSEQCNT")
      super()

      # If the user passed in an string, then they're indicating that we should 
      # operate on the packet, using the string as the name of the field to write.
      # If they pass in an integer, then they're indicating that we should operate
      # on the raw data and the integer is the byte location to write to
      @operateOnPacket = write_loc.is_a?(String)
      @write_loc = write_loc
    end


    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled sequence counter
    def write_packet(packet)
      
      if(@operateOnPacket)
        field_bit_size = packet.get_item(@write_loc).bit_size

        # if the value is too large for the field, it will error, so automatically
        # wrap the value
        seqcnt = @interface.write_count % ( 2 ** field_bit_size -1) 

        # write the value into the packet
        packet.write(@write_loc, seqcnt)
      end

      return super(packet)
    end

    # Called to perform modifications on data before it is written to the interface
    # Does nothing but calls the superclass method
    #
    # @param data [String] Raw packet data
    # @return [String] Packet data
    def write_data(data)

      if(!@operateOnPacket)
        # if the value is too large for the field, it will error, so automatically
        # wrap the value
        seqcnt = @interface.write_count % 16383 

      end

      return super(data)
    end



  end
end
