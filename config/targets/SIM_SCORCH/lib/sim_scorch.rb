require 'cosmos'
module Cosmos
  class SimScorch < SimulatedTarget
    def initialize(target_name)
      super(target_name)

	  # initalize so that the init status message is sent
	  @status = 172 # AC = INITALIZED
	  @send_response = true
	  
      # We grab the STATUS packet to set initial values
      packet = @tlm_packets['STATUS']
      packet.enable_method_missing # required to use packet.<item> = value
      packet.status = @status
	  
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
	  
	    # check the APID
	    if packet.read("CCSDSAPID") == 200
	      case packet.read("FCNCODE")
		    when 0 # NOOP
		      # no change
		    when 1 # STATUS request
		      # no change in status
	        @send_response = true
		    when 10 # ARM 
		      @status = 170 # AA = ARMED
		      @send_response = true
		    when 13 # DISARM
		      @status = 221 # DD = DISARMED
		      @send_response = true
		    when 15 # FIRE
		      @status = 255 # FF = FIRED
		      @send_response = true
		    else
		      @status = 187 # BB = unrecognized command
		      @send_response = true
		    end
	    else
	      @status = 175 # AF = unrecognized message
		    @send_response = true
	    end
	
    end

    def read(count_100hz, time)
      # The SimulatedTarget implements get_pending_packets to return
      # packets at the correct time interval based on their rates
	  
	    # pending_packets = get_pending_packets(count_100hz)
      pending_packets = [] 
	  
	    if @send_response 
	      # add the status packet to the list of output packets
	      packet = @tlm_packets['STATUS']

		    # update the packet payload
        packet.status = @status
       
	      # update header data
        packet.CCSDSVER = 1
        packet.CCSDS_SEC = time.tv_sec
        packet.CCSDS_SUBSEC = 0 #time.tv_usec
        packet.CCSDSSEQCNT += 1
		
		    # set send_respond back to false
		    @send_response = false
        
        pending_packets << packet
       
      end
	  
      pending_packets
    end
  end
end