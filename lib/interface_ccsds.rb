require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'
require 'ccsds.rb'
require 'xbee.rb'
require 'rfd900.rb'

module Cosmos
class InterfaceCcsds < SerialInterface
  def pre_write_packet(packet)
  
    # packet.buffer appears to be a string and is hard to manipulate
    data = packet.buffer
    
    # update the packet length
    data = update_ccsds_length(data)
    
    # update the packet checksum
    data = update_ccsds_checksum(data)
    puts data
    return data
  end

  def post_read_data(packet_data)
    #len = packet_data.length
    #
    # save the checksum from the packet
    #rx_checksum = packet_data[7] # Unpack as 16 bit unsigned big endian
    
    # initalize the checksum
    #calc_checksum = 0xFF
    
    # loop through the packet to calculate the checksum
    #packet_data.each_byte {|x| calc_checksum ^= x }
    
    # compare the value in the packet to what was calculated
    #if calc_checksum == rx_checksum
    #  return packet_data
    #else
    #  puts "Bad checksum detected. Calculated: 0x#{calc_checksum.to_s(16)} Received: 0x#{rx_checksum.to_s(16)}. Dropping packet."
    #  return "" # Also can return nil to break the connection and reconnect to the target
    #end
    puts packet_data
    return packet_data
  end

end
end