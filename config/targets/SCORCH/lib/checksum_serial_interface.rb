require 'cosmos' # always require cosmos
require 'cosmos/interfaces/serial_interface' # original interface being extended

module Cosmos
class ChecksumSerialInterface < SerialInterface
  def pre_write_packet(packet)
    data = packet.buffer
    checksum = 0xFFFF
    data.each_byte {|x| checksum += x }
    checksum &= 0xFFFF
    data << [checksum].pack("n") # Pack as 16 bit unsigned bit endian
    return data
  end

  def post_read_data(packet_data)
    len = packet_data.length
    calc_checksum = 0xFFFF
    packet_data[0..(len - 3)].each_byte {|x| calc_checksum += x }
    calc_checksum &= 0xFFFF
    rx_checksum = packet_data[-2..-1].unpack("n") # Unpack as 16 bit unsigned big endian
    if calc_checksum == rx_checksum
      return packet_data
    else
      puts "Bad checksum detected. Calculated: 0x#{calc_checksum.to_s(16)} Received: 0x#{rx_checksum.to_s(16)}. Dropping packet."
      return "" # Also can return nil to break the connection and reconnect to the target
    end
  end

end
end