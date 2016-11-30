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
      return createRFD900Pkt(packet_data,104,'MAVLINK')
      return createRFD900MavlinkPkt(packet_data) 
    elsif(isRFD900Str(packet_data,"FORMAT"))
      puts "Found Radio Format msg!" 
      return createRFD900Pkt(packet_data,105,'FORMAT')
    elsif(isRFD900Str(packet_data,"AIR_SPEED"))
      puts "Found Radio AirSpeed msg!" 
      return createRFD900Pkt(packet_data,106,'AIR_SPEED')
    elsif(isRFD900Str(packet_data,"SERIAL_SPEED"))
      puts "Found Radio SerialSpeed msg!" 
      return createRFD900Pkt(packet_data,107,'SERIAL_SPEED')
    elsif(isRFD900Str(packet_data,"TXPOWER"))
      puts "Found Radio TxPower msg!" 
      return createRFD900Pkt(packet_data,108,'TXPOWER')
    elsif(isRFD900Str(packet_data,"NETID"))
      puts "Found Radio NetID msg!"
      return createRFD900Pkt(packet_data,109,'NETID')
    elsif(isRFD900Str(packet_data,"ECC"))
      puts "Found Radio ECC msg!" 
      return createRFD900Pkt(packet_data,110,'ECC')
    elsif(isRFD900Str(packet_data,"OPPRESEND"))
      puts "Found Radio AirSpeed msg!" 
      return createRFD900Pkt(packet_data,111,'OPPRESEND')
    elsif(isRFD900Str(packet_data,"MIN_FREQ"))
      puts "Found Radio MinFreq msg!" 
      return createRFD900Pkt(packet_data,112,'MIN_FREQ')
    elsif(isRFD900Str(packet_data,"MAX_FREQ"))
      puts "Found Radio MaxFreq msg!" 
      return createRFD900Pkt(packet_data,113,'MAX_FREQ')
    elsif(isRFD900Str(packet_data,"NUM_CHANNELS"))
      puts "Found Radio NUM_CHANNELS msg!" 
      return createRFD900Pkt(packet_data,114,'NUM_CHANNELS')
    elsif(isRFD900Str(packet_data,"DUTY_CYCLE"))
      puts "Found Radio DUTY_CYCLE msg!" 
      return createRFD900Pkt(packet_data,115,'DUTY_CYCLE')
    elsif(isRFD900Str(packet_data,"LBT_RSSI"))
      puts "Found Radio LBT_RSSI msg!" 
      return createRFD900Pkt(packet_data,116,'LBT_RSSI')
    elsif(isRFD900Str(packet_data,"MANCHESTER"))
      puts "Found Radio MANCHESTER msg!" 
      return createRFD900Pkt(packet_data,117,'MANCHESTER')
    elsif(isRFD900Str(packet_data,"RTSCTS"))
      puts "Found Radio RTSCTS msg!" 
      return createRFD900Pkt(packet_data,118,'RTSCTS')
    elsif(isRFD900Str(packet_data,"NODEID"))
      puts "Found Radio NODEID msg!" 
      return createRFD900Pkt(packet_data,119,'NODEID')
    elsif(isRFD900Str(packet_data,"NODEDESTINATION"))
      puts "Found Radio NODEDESTINATION msg!" 
      return createRFD900Pkt(packet_data,120,'NODEDESTINATION') 
    elsif(isRFD900Str(packet_data,"SYNCANY"))
      puts "Found Radio SYNCANY msg!" 
      return createRFD900Pkt(packet_data,121,'SYNCANY') 
    elsif(isRFD900Str(packet_data,"NODECOUNT"))
      puts "Found Radio NODECOUNT msg!" 
      return createRFD900Pkt(packet_data,122,'NODECOUNT') 
    else
      puts "Unrecognized message: "
      return packet_data
    end
  end

end
end