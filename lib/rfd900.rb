
def appendRFD900Term(data)

  return data << "\x0D\x0A"
end

def isRFD900StatStr(packet_data)

  if(packet_data.include?("pkts") && packet_data.include?("txe") && packet_data.include?("rxe") && packet_data.include?("stx"))
    return true
  else
    return false
  end

end

def isRFD900RSSIStr(packet_data)

  if(packet_data.include?("RSSI") && packet_data.include?("noise"))
    return true
  else
    return false
  end
end

def isRFD900Str(packet_data,str)

  if(packet_data.include?(str))
    return true
  else
    return false
  end
end


def createRFD900StatPkt(packet_data)
  regex_format = /\[(\d+)\] pkts: (\d+) txe=(\d+) rxe=(\d+) stx=(\d+) srx=(\d+) ecc=(\d+)\/(\d+) temp=(\d+) dco=(\d+)/
  nodeid = ["%02x" % packet_data[regex_format,1].to_i].pack("H*")
  pkts = ["%04x" % packet_data[regex_format,2].to_i].pack("H*")
  txe = ["%04x" % packet_data[regex_format,3].to_i].pack("H*")
  rxe = ["%04x" % packet_data[regex_format,4].to_i].pack("H*")
  stx = ["%04x" % packet_data[regex_format,5].to_i].pack("H*")
  srx = ["%04x" % packet_data[regex_format,6].to_i].pack("H*")
  ecc1 = ["%04x" % packet_data[regex_format,7].to_i].pack("H*")
  ecc2 = ["%04x" % packet_data[regex_format,8].to_i].pack("H*")
  temp = ["%04x" % packet_data[regex_format,9].to_i].pack("H*")
  dco = ["%04x" % packet_data[regex_format,10].to_i].pack("H*")
  
  # create the forward message command including the destination address
  rtn_pkt = "\x08\x65\x00\x00\x00\x2D\x38\x6D\x58\x47\x00\x00".force_encoding('ASCII-8BIT') << nodeid << pkts << txe << rxe << stx << srx << ecc1 << ecc1 << temp << dco
  return rtn_pkt
  
end

def createRFD900RSSIPkt(packet_data)

  regex_format = /\[(\d+)\] L\/R RSSI: (\d+)\/(\d+)  L\/R noise: (\d+)\/(\d+)/
  nodeid = ["%02x" % packet_data[regex_format,1].to_i].pack("H*")
  local_rssi = ["%04x" % packet_data[regex_format,2].to_i].pack("H*")
  remote_rssi = ["%04x" % packet_data[regex_format,3].to_i].pack("H*")
  local_noise = ["%04x" % packet_data[regex_format,4].to_i].pack("H*")
  remote_noise = ["%04x" % packet_data[regex_format,5].to_i].pack("H*")
  
  # create the forward message command including the destination address
  rtn_pkt = "\x08\x66\x00\x00\x00\x15\x38\x6D\x58\x47\x00\x00".force_encoding('ASCII-8BIT') << nodeid << local_rssi << remote_rssi << local_noise << remote_noise
  p rtn_pkt
  return rtn_pkt
  
end

def createRFD900NodeCntPkt(packet_data)

  regex_format = /\[(\d+)\] NODECNT (\d+)/
  nodecnt = ["%02x" % packet_data[regex_format,1].to_i].pack("H*")
  
  # create the forward message command including the destination address
  rtn_pkt = "\x08\x67\x00\x00\x00\x0D\x38\x6D\x58\x47\x00\x00".force_encoding('ASCII-8BIT') << nodecnt
  p rtn_pkt
  return rtn_pkt
  
end