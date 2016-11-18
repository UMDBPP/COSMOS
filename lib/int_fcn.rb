


def isPayloadPkt(packet_data, payload)
  require 'json'
  
  # read json definition file
  file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))

  # parse the json
  net = JSON.parse(file)
    
  # get the APID from the packet
  apid = get_CCSDSAPID(packet_data)

  # loop through each packet defined
  net[payload].each do |key, value|
    # if the apid of the packet is one of Link's return true
    if(apid.to_s() == key)
      return true
    end
  end
  
  # if we made it this far then the APID isn't one of links, return false
  return false
end


def prepend_fwdmsgcmd(packet_data)
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
  addr_str= ["%02x" % addr.to_i()].pack("H*")
  
  # create the forward message command including the destination address
  str = "\x10\xC8\xC0\x00\x00\x04\x28\x00".force_encoding('ASCII-8BIT') << addr_str
  
  # prepend the LINK XB_FwdMsg command to the command to be sent
  packet_data.prepend(str )
    
  return packet_data
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



