# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the checksum field of a CCSDS packet with an
  # 8 bit CRC
  class CcsdsProtocol < Protocol
  # @param write_loc [String] The name of the field which should be filled with the checksum
  # -OR-
  # @param write_loc [Int] Byte index in the packet of the checksum

    def initialize(write_loc = "CHECKSUM")
      super()

      # If the user passed in an string, then they're indicating that we should 
      # operate on the packet, using the string as the name of the field to write.
      # If they pass in an integer, then they're indicating that we should operate
      # on the raw data and the integer is the byte location to write to
      @operateOnPacket = write_loc.is_a?(String)
      
      # assign to a class property so that its accessible in the methods
      @write_loc = write_loc
      
    end

    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled checksum
    def write_packet(packet)

      if(@operateOnPacket)
        # need to zero the field in case
        #  its not zero, which would affect the checksum, 0 ^ X = X so zero doesn't affect checksum
        #  the checksum has already been set, which would result in zero checksum, X ^ X = 0
        packet.write(@write_loc, 0)

        # write the value into the packet
        # Note: this will fail if the field doesn't exist, so hopefully they only call this on a command!
        packet.write(@write_loc, calcChecksum(packet.buffer))
      end
      
      return super(packet)
    end
    
    # Called to perform modifications on data before it is written to the interface
    #
    # @param data [String] Raw packet data
    # @return [String] Packet data
    def write_data(data)
    
      if(!@operateOnPacket)
      
        # need to zero the field in case
        #  its not zero, which would affect the checksum, 0 ^ X = X so zero doesn't affect checksum
        #  the checksum has already been set, which would result in zero checksum, X ^ X = 0
        packet.buffer[@write_loc] = [0].pack('U')
        
        # write the checksum back into the packet
        data[@write_loc] = [calcChecksum(packet.buffer)].pack('U')
        
      end
      
      return super(data)
    end
    
    def calcChecksum(data)
    
      # calculate checksum
      checksum = 0xFF
      data.each_byte {|x| checksum ^= x }
      
      return checksum
    end
  end
end
