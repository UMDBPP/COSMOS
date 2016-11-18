
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