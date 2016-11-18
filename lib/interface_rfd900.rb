require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'
require 'ccsds.rb'
require 'xbee.rb'
require 'rfd900.rb'

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
      return createRFD900RSSIPkt(packet_data)
    elsif(isRFD900Str(packet_data,"NODECNT"))
      puts "Found Radio NodeCnt msg!"
      return createRFD900NodeCntPkt(packet_data)
    elsif(isRFD900Str(packet_data,"MAVLINK"))
      puts "Found Radio Mavlink msg!" 
      
      
    elsif(isRFD900Str(packet_data,"NODEID"))
      puts "Found Radio NodeID msg!"
      
      
    elsif(isRFD900Str(packet_data,"NETID"))
      puts "Found Radio NetID msg!"

    elsif(isRFD900Str(packet_data,"TXPWR"))
      puts "Found Radio TXPwr msg!" 
      
    elsif(isRFD900Str(packet_data,"AIRRATE"))
      puts "Found Radio AirRate msg!"  
      
    elsif(isRFD900Str(packet_data,"NODEDEST"))
      puts "Found Radio NodeDest msg!" 
      
    elsif(isRFD900Str(packet_data,"BAUD"))
      puts "Found Radio SerialBaud msg!" 

    elsif(isRFD900Str(packet_data,"MIN_FREQ"))
      puts "Found Radio MinFreq msg!" 
      
    elsif(isRFD900Str(packet_data,"MAX_FREQ"))
      puts "Found Radio MaxFreq msg!" 
      
    elsif(isRFD900Str(packet_data,"NUM_CHAN"))
      puts "Found Radio NumChannels msg!" 
      
    else
      puts "Unrecognized message: "
      return packet_data
    end
  end

end
end