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


def createRFD900Pkt(packet_data,apid,srch_str)

  regex_format = /\[(\d+)\] S(\d+): #{srch_str}=(\d+)/
  val = to_byte_array(packet_data[regex_format,3].to_i)
  
  # create the forward message command including the destination address
  rtn_pkt = [0x08, apid, 0x00, 0x00, 0x00, 0x0E, 0x38, 0x6D, 0x58, 0x47, 0x00, 0x00] + val
  rtn_pkt = rtn_pkt.collect{|i| i.to_i.to_s(16).hex.chr}.join()

  p rtn_pkt
  return rtn_pkt
  
end
 def to_byte_array(num)
    result = []
    begin
      result << (num & 0xff)
      num >>= 8
    end until (num == 0 || num == -1) && (result.last[7] == num[7])
    result.reverse
  end
end
end
