# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'


module Cosmos
  # Protocol which fills the checksum field of a CCSDS packet with an
  # 8 bit CRC
  class CcsdsProtocol < Protocol
  # @param checksum_field_name [String] The name of the field which should be filled with the checksum

    def initialize(checksum_field_name = "CHECKSUM")
      super()
      @checksum_field_name = checksum_field_name

    end

    # Called to perform modifications on the packet before writing the data
    #
    # @param data [Packet] Packet object
    # @return [Packet] Packet object with filled checksum
    def write_packet(packet)

      # calculate checksum
      checksum = 0xFF
      packet.buffer.each_byte {|x| checksum ^= x }

      # write the value into the packet
      # Note: this will fail if the field doesn't exist, so hopefully they only call this on a command!
      packet.write(@checksum_field_name, checksum)

      return super(packet)
    end
  end
end
