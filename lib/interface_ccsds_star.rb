require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'
require 'ccsds.rb'
require 'xbee.rb'
require 'rfd900.rb'

module Cosmos
class InterfaceCcsdsStar < SerialInterface
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
    
    # echo all messages to the window
    if(get_CCSDSAPID(packet_data) == 120)
      puts "STAR " + (get_CCSDSTlmSec(packet_data)).to_s() + "." + (get_CCSDSTlmSubSec(packet_data)).to_s() + ": " + (getCCSDSTlmPayload(packet_data)).to_s()
    end
    
    #puts packet_data
    return packet_data
  end

end
end