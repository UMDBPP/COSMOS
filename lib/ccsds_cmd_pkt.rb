# encoding: ascii-8bit

# Copyright 2014 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

require 'cosmos/ccsds/ccsds_packet'

module Cosmos

  # Packet which defines the required CCSDS items which include Version, Type,
  # Secondary Header Flag, APID, Sequence Flags, Sequence Count and Length. It
  # will optionally include a data item which will contain the rest of the
  # CCSDS packet data. This is optional to make it easier to subclass this
  # packet and add secondary header fields.
  class CcsdsCmdPacket < CcsdsPacket

    # Creates a CCSDS packet by setting the target and packet name and then
    # defining all the fields in a CCSDS packet with a primary header. If a
    # secondary header is desired, define a secondary header field and then
    # override the CcsdsData field to start after bit offset 48.
    #
    # @param target_name [String] The target name
    # @param packet_name [String] The packet name
    def initialize(target_name = nil, packet_name = nil, include_ccsds_data = false)
      super(target_name, packet_name, include_ccsds_data)
      define_item('FcnCode', 48, 8, :UINT)
      define_item('Checksum', 56, 8, :UINT)
      define_item('CcsdsData', 64, 0, :BLOCK) if include_ccsds_data
    end

  end

end # module Cosmos
