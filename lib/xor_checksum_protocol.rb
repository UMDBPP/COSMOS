# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the checksum field of a CCSDS packet with an
  # 8 bit, XOR CRC and validates the checksum of incoming packets
  class XorChecksumProtocol < Protocol
  # @param write_loc [String] The name of the field which should be filled with the checksum

    def initialize(checksum_item_name = "CHECKSUM")

      raise "Invalid checksum_item_name of '#{checksum_item_name}'. Must be the name of a field in the packet." if checksum_item_name.to_s.upcase == "NIL"

      # convert arguments
      @checksum_item_name = checksum_item_name.to_s
            
    end

    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled checksum
    def write_packet(packet)
    
      # need to zero the field in case
      #  its not zero, which would affect the checksum, 0 ^ X = X so zero doesn't affect checksum
      #  the checksum has already been set, which would result in zero checksum, X ^ X = 0
      packet.write(@checksum_item_name, 0)

      # write the value into the packet
      # Note: this will fail if the field doesn't exist, so hopefully they only call this on a command!
      packet.write(@checksum_item_name, calcChecksum(packet.buffer))
      
      return packet
    end

  end
end
