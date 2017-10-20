# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/protocols/protocol'
require 'cosmos/packets/binary_accessor'


module Cosmos
  # Protocol which fills the checksum field of a CCSDS packet with an
  # 8 bit, XOR CRC 
  class XorChecksumProtocolRaw < Protocol
  # @param checksum_byte_offset [Integer] The byte offset of the checksum field

    def initialize(checksum_byte_offset = 7)

      # convert arguments
      @checksum_byte_offset = Integer(checksum_byte_offset)
            
    end

    # Called to perform modifications on write data before writing to the interface
    #
    # @param data [String] Raw packet data
    # @return [String] Potentially modified packet data
    def write_data(data)
    
      # need to zero the checksum field in case:
      #  its not zero, which would affect the checksum, 0 ^ X = X so zero doesn't affect checksum
      #  the checksum has already been set, which would result in zero checksum, X ^ X = 0
      BinaryAccessor.write(0, 
                           @checksum_byte_offset*8, 
                           8, 
                           :UINT,
                           data, 
                           @endianness, 
                           :ERROR)

      # write the value into the packet
      BinaryAccessor.write(calcChecksum(data), 
                           @checksum_byte_offset*8, 
                           8, 
                           :UINT,
                           data, 
                           @endianness, 
                           :ERROR)
      
      return data
    end
        
    # calculates an 8bit XOR checksum of a byte array
    def calcChecksum(data)
    
      # calculate checksum
      checksum = 0xFF
      data.each_byte {|x| checksum ^= x }
      
      return checksum
    end
  end
end
