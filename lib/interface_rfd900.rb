require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'

module Cosmos
class InterfaceRfd900 < SerialInterface
  def pre_write_packet(packet)
  
    # packet.buffer appears to be a string and is hard to manipulate
    data = packet.buffer
      
    if(isPayloadPkt(data, 'RFD900'))
      puts "Found RFD900 packet!"
      # if its an enter AT mode command, don't append CR+NL
      
      if(get_CCSDSFcnCode(data) == 10)
        p "Found AT cmd"
        data = getCCSDSCmdPayload(data)
      else
        data = getCCSDSCmdPayload(data)
        # append CR+NL
        data = appendRFD900Term(data)
      end
      p data
      return data  
    end      
      
    return data
  end

  def post_read_data(packet_data)

    p "Received: "
    p packet_data
    
    if(isRFD900StatStr(packet_data))
      puts "Found Radio HK msg!"
      rtn_pkt = createRFD900StatPkt(packet_data)
      return rtn_pkt
    elsif(isRFD900RSSIStr(packet_data))
      puts "Found Radio RSSI msg!"
      rtn_pkt = createRFD900RSSIPkt(packet_data)
      return rtn_pkt
    else
      return packet_data
    end
  end

end
end