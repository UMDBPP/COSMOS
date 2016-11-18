require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'
require 'ccsds.rb'
require 'xbee.rb'
require 'rfd900.rb'

module Cosmos
class InterfaceCcsdsXbee < SerialInterface
  def pre_write_packet(packet)
  
    # packet.buffer appears to be a string and is hard to manipulate
    data = packet.buffer
   
    if(!isXbeePkt(data))
      puts "Found non-xbee packet!"
      
      # update the packet length for the packet being sent
      data = update_ccsds_length(data)
    
      # update the packet checksum for the packet being sent
      data = update_ccsds_checksum(data)
    
      # prepend the link command to forward the data if its not a link command
      data = prepend_xbeecmd(data)
      
    else
      puts "Found xbee packet!"
      
    end  
        
    # update the packet length
    data = update_xbee_length(data)
        
    # update the packet checksum
    data = update_xbee_checksum(data)
        
    # debug
    p data
    
    return data
  end

  def post_read_data(packet_data)
    
    # http://knowledge.digi.com/articles/Knowledge_Base_Article/Calculating-the-Checksum-of-an-API-Packet
    #To verify the check sum of an API packet add all bytes including the checksum (do not include the delimiter and length) 
    # and if correct, the last two far right digits of the sum will equal FF.
        
    # initalize checksum
    calc_checksum = 0
        
    # loop through the packet to calculate the checksum
    packet_data[3..-1].each_byte {|x| calc_checksum += x }
        
    calc_checksum &= 0xFF
    
    # compare the value in the packet to what was calculated
    if calc_checksum == 0xFF
      # debugging output
      puts "Packet with good checksum! 0x#{calc_checksum.to_s(16)}"
      p packet_data
      
      # if this packet is an RX packet, strip the header so that the received packet is processed
      if(packet_data[3].unpack("C").first == 129)
      
        # RX packet has a header 8 bytes long and has a 1 byte checksum at the end
        packet_data = packet_data[8..-2]
      end
      
      return packet_data
    else
      puts "Bad checksum detected. Calculated: 0x#{calc_checksum.to_s(16)} Received: 0x#{packet_data[-1].unpack("C").first}. Dropping packet."
      return "" # Also can return nil to break the connection and reconnect to the target
    end
  end

end
end