require 'cosmos' # always require cosmos
require 'cosmos/interfaces/protocols/protocol' # original interface being extended

#require 'json'
    
module COSMOS
  class LinkProtocol < Protocol

    def initialize()
      super()
    
      # read json definition file needed for the processing functions
      file = File.read(File.join(File.dirname(__FILE__),'APIDs.json'))
      # parse the json
      @net = JSON.parse(file)
    end

    def write_data(data)
      if(!isPayloadPkt(data,'LINK'))
        puts "Found non-link packet, forwarding to intended payload!"
        
        # prepend the link command to forward the data if its not a link command
        data = prepend_fwdmsgcmd(data)
          
      else
        puts "Found link packet!"
      end
      
      return data
    end
    def isPayloadPkt(packet_data, payload)
  
      # get the APID from the packet
      apid = get_CCSDSAPID(packet_data)

      # loop through each packet defined
      @net[payload].each do |key, value|
        # if the apid of the packet is one of Link's return true
        if(apid.to_s() == key)
          return true
        end
      end
  
      # if we made it this far then the APID isn't one of links, return false
      return false
    end


    def prepend_fwdmsgcmd(packet_data)
    
      # get the APID from the packet
      apid = get_CCSDSAPID(packet_data)
  
      # need to figure out which address to send have LINK forward the packet to
      addr = getAddrFromApid(apid)
  
      # encode that address as a hex string
      addr_str= ["%02x" % addr.to_i()].pack("H*")
  
      # create the forward message command including the destination address
      str = "\x10\xC8\xC0\x00\x00\x04\x28\x00".force_encoding('ASCII-8BIT') << addr_str
  
      # prepend the LINK XB_FwdMsg command to the command to be sent
      packet_data.prepend(str )
    
      return packet_data
    end
    
    def getAddrFromApid(apid)
      # initalize variables
      found_addr = false
      addr = 0
  
      # loop through each payload defined
      @net.each do |key, value|
        # loop through each packet defined for that played
        @net[key].each do |key2,val2|
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
    end
    
  end
end
