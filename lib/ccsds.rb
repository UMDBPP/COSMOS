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

def get_CCSDSAPID(packet_data)

  # extract the APID from the StreamID field
  apid = ((packet_data[0].unpack("C").first * 256) + packet_data[1].unpack("C").first) & 2047

  return apid
end

def get_CCSDSFcnCode(packet_data)

  # extract the APID from the StreamID field
  apid = packet_data[6].unpack("C").first & 0x7F

  return apid
end

def getCCSDSCmdPayload(packet_data)

  return packet_data[8..-1]
end
