

def update_ccsds_length(packet_data)

    # update the packet length
    # this is needed because the XB_FWDMSG and GND_FSWMSG commands are dynamic length
    # NOTE: packet.length returns the size of the packet in the database, not the actual length of the packet
    #   doesn't look like it can be used for dynamic length packets 
    packet_data[4..5] = [packet_data.length-7].pack("n")

    # return the data with the length field updated
    return packet_data
end

def update_ccsds_checksum(packet_data)

   # calculate the checksum
    checksum = 0xFF
    packet_data.each_byte {|x| checksum ^= x }
    
    # debug statement
    #puts "checksum 0x#{checksum.to_s(16)}"
    
    # not sure why the pack is necessary for assigning into an element of the data array
    packet_data[7] = [checksum].pack("C")

    # return the data with the length field updated
    return packet_data
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

def isLinkPkt(packet_data)
  require 'json'
  
  # read json definition file
  file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))

  # parse the json
  net = JSON.parse(file)
    
  # get the APID from the packet
  apid = get_APID(packet_data)
  
  # loop through each packet defined
  net['LINK'].each do |key, value|
    # if the apid of the packet is one of Link's return true
    if(apid.to_s() == key)
      return true
    end
  end
  
  # if we made it this far then the APID isn't one of links, return false
  return false
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

def prepend_fwdmsgcmd(packet_data)
  require 'json'
  
  # read json definition file
  file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))

  # parse the json
  net = JSON.parse(file)
  
  # get the APID from the packet
  apid = get_APID(packet_data)
  
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
  str = "\x10\x64\xC0\x00\x00\x03\x19\x63\x02".force_encoding('ASCII-8BIT') << addr_str
  
  puts str
  puts packet_data
  
  # prepend the LINK XB_FwdMsg command to the command to be sent
  packet_data.prepend(str )
  
  puts packet_data
  
  return packet_data
end

def prepend_xbeecmd(packet_data)
  require 'json'
  
  # read json definition file
  file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))

  # parse the json
  net = JSON.parse(file)
  
  # get the APID from the packet
  apid = get_APID(packet_data)
  
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


def get_APID(packet_data)

  # extract the APID from the StreamID field
  apid = ((packet_data[0].unpack("C").first * 256) + packet_data[1].unpack("C").first) & 2047

  return apid
end