# encoding: ascii-8bit

# Copyright 2017 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

require 'cosmos/packets/binary_accessor'
require 'cosmos/interfaces/protocols/protocol'
require 'cosmos/config/config_parser'

module Cosmos
  # Protocol which delineates packets using a length field at a fixed
  # location in each packet.
  class LengthProtocolRaw < Protocol
    # @param length_bit_offset [Integer] The bit offset of the length field
    # @param length_bit_size [Integer] The size in bits of the length field
    # @param length_value_offset [Integer] The offset to apply to the length
    #   value once it has been read from the packet. The value in the length
    #   field itself plus the length value offset MUST equal the total bytes
    #   including any discarded bytes.
    #   For example: if your length field really means "length - 1" this value should be 1.
    # @param length_bytes_per_count [Integer] The number of bytes per each
    #   length field 'count'. This is used if the units of the length field is
    #   something other than bytes, for example words.
    # @param length_endianness [String] The endianness of the length field.
    #   Must be either BIG_ENDIAN or LITTLE_ENDIAN.

    def initialize(
      length_bit_offset = 0,
      length_bit_size = 16,
      length_value_offset = 0,
      length_bytes_per_count = 1,
      length_endianness = 'BIG_ENDIAN'
    )

      # Save length field attributes
      @length_bit_offset = Integer(length_bit_offset)
      @length_bit_size = Integer(length_bit_size)
      @length_value_offset = Integer(length_value_offset)
      @length_bytes_per_count = Integer(length_bytes_per_count)

      # Save endianness
      if length_endianness.to_s.upcase == 'LITTLE_ENDIAN'
        @length_endianness = :LITTLE_ENDIAN
      else
        @length_endianness = :BIG_ENDIAN
      end

    end

    # Called to perform modifications on write data before making it into a packet
    #
    # @param data [String] Raw packet data
    # @return [String] Potentially modified packet data
    def write_data(data)

      BinaryAccessor.write(calculate_length(data.length), @length_bit_offset, @length_bit_size, :UINT,
                           data, @length_endianness, :ERROR)

      return data
    end

    protected

    def calculate_length(buffer_length)
      length = (buffer_length / @length_bytes_per_count) - @length_value_offset
      if @max_length && length > @max_length
        raise "Calculated length #{length} larger than max_length #{@max_length}"
      end
      length
    end

  end
end
