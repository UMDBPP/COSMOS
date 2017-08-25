require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended
require 'int_fcn.rb'
require 'ccsds.rb'
require 'xbee.rb'
require 'rfd900.rb'

module Cosmos
class InterfaceCcsdsLink < SerialInterface
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
    else
      
      # if the packet is not a link message, prepend a LINK command to foward
      # the message to the appropriate payload
      if(!isPayloadPkt(data,'LINK'))
        puts "Found non-link packet, forwarding to intended payload!"
        
        # update the packet length for the LINK forward command
        data = update_ccsds_length(data)
      
        # update the packet checksum for the LINK forward command
        data = update_ccsds_checksum(data)
        
        # prepend the link command to forward the data if its not a link command
        data = prepend_fwdmsgcmd(data)
        
      else
        puts "Found link packet!"
      end
     
      # update the packet length for the packet being sent
      data = update_ccsds_length(data)
      
      # update the packet checksum for the packet being sent
      data = update_ccsds_checksum(data)
              
      p data
      
      return data
    end
  end

  def post_read_data(packet_data)

    # loop through the packet to calculate the checksum
    #packet_data.each_byte {|x| calc_checksum ^= x }
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
    return packet_data
  end

end
end