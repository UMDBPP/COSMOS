require 'cosmos' # always require cosmos
require 'cosmos/interfaces/protocols/protocol' # original interface being extended

module Cosmos
class XbeeProtocol < Protocol
  def write_data(data)
  
    # packet.buffer appears to be a string and is hard to manipulate
    data = packet.buffer
   
    if(!isXbeePkt(data))
      puts "Found non-xbee packet!"
    
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

def update_xbee_length(packet_data)

    # update the packet length
    packet_data[1..2] = [packet_data.length-3].pack("n")

    # return the data with the length field updated
    return packet_data
end

def update_xbee_checksum(packet_data)

  # calculate the checksum
  # initalize to zero
  checksum = 0x00
    
  # add all bytes
  packet_data[3..-1].each_byte {|x| checksum += x }
    
  # take only bottom 8 bits
  checksum &= 0xFF
    
  # subtract from 0xFF
  checksum = 0xFF - checksum
    
  # http://knowledge.digi.com/articles/Knowledge_Base_Article/Calculating-the-Checksum-of-an-API-Packet
  # To calculate the check sum you add all bytes of the packet excluding the frame delimiter 7E and the length (the 2nd and 3rd bytes).
  # Now take the result and keep only the lowest 8 bits (the two far right digits). Subtract from 0xFF and you get the checksum for this data packet.
    
  # debug statement
  #p "checksum 0x#{checksum.to_s(16)}"
    
  # not sure why the pack is necessary for assigning into an element of the data array
  packet_data << [checksum].pack("C")

  return packet_data
end


def isXbeePkt(packet_data)

  # debugging statement
  #p packet_data[0].unpack("C").first 
  
  if(packet_data[0].unpack("C").first == 126) # = 0x7E
    return true
  else
    return false
  end

end


def prepend_xbeecmd(packet_data)
  require 'json'
  
  # read json definition file
  file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))

  # parse the json
  net = JSON.parse(file)
  
  # get the APID from the packet
  apid = get_CCSDSAPID(packet_data)
  
  # need to figure out which address to send have LINK forward the packet to
  
  # initalize variables
  found_addr = false
  addr = 0
  
  # loop through each payload defined
  net.each do |key, value|
    # loop through each packet defined for that played
    net[key].each do |key2,val2|
      # if the apid of the packet is one of that payloads record it and break loop
      if(apid.to_s() == key2)
        found_addr = true
        break
      end
    end
    # if this payload is the owner of the packet, record the xbee address of that payload
    if(found_addr)
      addr = net[key]['XBEE']
      break
    end
  end
  
  # encode that address as a hex string
  addr_str = ["%02x" % addr.to_i()].pack("H*")
  
  # create the forward message command including the destination address
  # NOTE: Only supports xbee address 0-255 for now, need to figure out how to encode 2 byte
  str = "\x7E\x00\x05\x01\x01\x00".force_encoding('ASCII-8BIT') << addr_str << "\x00".force_encoding('ASCII-8BIT')
  
  # prepend the LINK XB_FwdMsg command to the command to be sent
  packet_data.prepend(str)
  
  # debug statement
  #puts packet_data
  
  return packet_data
end


end
end
