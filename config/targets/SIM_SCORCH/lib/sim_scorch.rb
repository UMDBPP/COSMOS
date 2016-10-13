require 'cosmos'
module Cosmos
  class SimScorch < SimulatedTarget
    def initialize(target_name)
      super(target_name)

      # We grab the STATUS packet to set initial values
      packet = @tlm_packets['STATUS']
      packet.enable_method_missing # required to use packet.<item> = value
      packet.status = "INITALIZED" # 172 = INITALIZED
    end

    def set_rates
      # The SimulatedTarget operates on a 100Hz clock
      # Thus the rates are determined by dividing this rate
      # by the set rate to get the output rate of the packet
      # set_rate('STATUS', 100) # 100 / 100 = 1Hz
      # set_rate('DATA', 10) # 100 / 10 = 10Hz
    end

    def write(packet)
      # We directly set the telemetry value from the only command
      # If you have more than one command you'll need to switch
      # on the packet.packet_name to determine what command it is
	  fcncode = packet.read("fcncode")
	  if(fcncode == 0) # NOOP
	    # no change
	  elsif(fcncode == 1) # STATUS request
	    @tlm_packets['STATUS'].status = 
	  elsif(fcncode == 10) # ARM 
	    @tlm_packets['STATUS'].status = 170 # AA = ARMED
	  elsif(fcncode == 13) # DISARM
	    @tlm_packets['STATUS'].status = 221 # DD = DISARMED
	  elsif(fcncode == 15) # FIRE
        @tlm_packets['STATUS'].status = 255 # FF = FIRED
      else
		@tlm_packets['STATUS'].status = 187 # unrecognized
	  end
#	STATE UNRECOGNIZED_MESSAGE 175
	
    end

    def read(count_100hz, time)
      # The SimulatedTarget implements get_pending_packets to return
      # packets at the correct time interval based on their rates
      pending_packets = get_pending_packets(count_100hz)

      pending_packets.each do |packet|
        case packet.packet_name
        when 'STATUS'
          packet.counter += 1
        when 'DATA'
          # This method in SimulatedTarget cycles the specified telemetry
          # point between the two given values by the given increment for
          # each packet sent out.
          cycle_tlm_item(packet, 'temp1', -95.0, 95.0, 1.0)

          packet.timesec = time.tv_sec
          packet.timeus  = time.tv_usec
          packet.counter += 1
        end
      end
      pending_packets
    end
  end
end