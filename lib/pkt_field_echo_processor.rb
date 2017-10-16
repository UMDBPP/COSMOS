# encoding: ascii-8bit

# Copyright 2014 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

require 'cosmos/processors/processor'

module Cosmos

  class PktFieldEchoProcessor < Processor
    # @param item_name [String] The name of the item to echo
    # @param value_type #See Processor::initialize
    def initialize(item_name, value_type = :CONVERTED)
      super(value_type)
      @item_name = item_name.to_s.upcase
      reset()
    end

    # Run statistics on the item
    #
    # See Processor#call
    def call(packet, buffer)
      value = packet.read(@item_name, @value_type, buffer)
      # also read and echo timestamp of packet?
      # value = packet.read(@item_name, @value_type, buffer)
      puts value
    end

    # Convert to configuration file string
    def to_config
      "  PROCESSOR #{@name} #{self.class.name.to_s.class_name_to_filename} #{@item_name} #{@value_type}\n"
    end

  end # class PktFieldEchoProcessor

end # module Cosmos