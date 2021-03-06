load 'cosmos/tools/test_runner/test.rb'

# This Test demonstrates the usage of the setup and teardown methods
# as well as defining two tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class CmdViaRadioTest < Cosmos::Test
  def initialize
    super()
  end

  # Setup the test case by doing stuff
  def setup
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    # if interfaces are not connected, try to connect
    #disconnect_interface("XBEE_INT")
    #wait(1)
    #connect_interface("XBEE_INT")

    disconnect_interface("LINKCCSDS_INT")
    wait(1)
    connect_interface("LINKCCSDS_INT")
    
    # set the MY address
    #cmd("XBEE", "ATSETCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "MY", "VAL" => 3)
    # request the MY parameter
    #cmd("XBEE", "ATCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "MY")
    # verify it was set correctly
    #wait_check("XBEE ATCMDRESP RESPONSE == 3", 0.5)

    # set the ID
    #cmd("XBEE", "ATSETCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "ID", "VAL" => 2827)
    # request the ID parameter
    #cmd("XBEE", "ATCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "ID")
    # verify it was set correctly
    #wait_check("XBEE ATCMDRESP RESPONSE == 2827", 0.5)
  end
  
  def test_01_reqhk_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_HK command works when received from radio"
    # we need this test first because many other tests need the data in the HK packet
    # to verify their functionality
    
    # request an HK packet
    cmd("LINK", "REQ_HK")

    # wait until we receive the HK packet in response
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
  end
  
  def test_02_reboot_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies that on startup the counters are zeroed."
    # we do this test early in the sequence because rebooting means that we
    # know the state of the software being tested for the rest of the sequence
        
    # reboot Link
    cmd_no_hazardous_check("LINK", "REBOOT")
    
    # wait for Link to reboot and reinitalize
    wait(5)
    
    # request telemetry to verify a reboot occured cmd
    # Note: No destination parameter is included intention to test the default
    cmd("LINK", "REQ_HK")
    
    # wait to receive the packet
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
    # check the values. If it didn't reboot as intentded then the CmdExeCtr
    # and/or CmdRejCtr would be non-zero (because test 1 would've incremented)
    # them. RADIORCVDBYTECTR is 9 because the HK_Pkt command used to initiate the
    # sending of the HK packet we're examining is 9 bytes long
    check("LINK HK_Pkt CMDREJCTR == 0")
    check("LINK HK_Pkt CMDEXECTR == 0")
    check("LINK HK_Pkt RADIORCVDBYTECTR == 9")
    check("LINK HK_Pkt RADIOSENTBYTECTR == 0")
    check("LINK HK_Pkt XBEERCVDBYTECTR == 0")
    check("LINK HK_Pkt XBEESENTBYTECTR == 0")
  end
  
  def test_03_noop_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command results in a command execution and that the REQ_HK command returns HK telemetry source: radio"
    
    # request HK telemetry so that we know the initial state of the counters
    cmd("LINK", "REQ_HK")
    
    # wait for the packet
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
    # record the initial values of each of the counters
    pre_cmd_rej = tlm_variable("LINK HK_Pkt CMDREJCTR", :CONVERTED)
    pre_cmd_exe = tlm_variable("LINK HK_Pkt CMDEXECTR", :CONVERTED)
    pre_cmd_rdio_rcvd = tlm_variable("LINK HK_Pkt RADIORCVDBYTECTR", :CONVERTED)
    pre_cmd_rdio_sent = tlm_variable("LINK HK_Pkt RADIOSENTBYTECTR", :CONVERTED)
    pre_cmd_xbee_rcvd = tlm_variable("LINK HK_Pkt XBEERCVDBYTECTR", :CONVERTED)
    pre_cmd_xbee_sent = tlm_variable("LINK HK_Pkt XBEESENTBYTECTR", :CONVERTED)
    
    # issue a NoOp cmd
    cmd("LINK", "NOOP")
    
    # give it a bit of time to be executed
    wait(0.1)

    # request new HK telemetry to verify NoOp cmd was executed
    cmd("LINK", "REQ_HK")
    
    # wait for packet 
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
    # record the values of each of the counters
    post_cmd_rej = tlm_variable("LINK HK_Pkt CMDREJCTR", :CONVERTED)
    post_cmd_exe = tlm_variable("LINK HK_Pkt CMDEXECTR", :CONVERTED)
    post_cmd_rdio_rcvd = tlm_variable("LINK HK_Pkt RADIORCVDBYTECTR", :CONVERTED)
    post_cmd_rdio_sent = tlm_variable("LINK HK_Pkt RADIOSENTBYTECTR", :CONVERTED)
    post_cmd_xbee_rcvd = tlm_variable("LINK HK_Pkt XBEERCVDBYTECTR", :CONVERTED)
    post_cmd_xbee_sent = tlm_variable("LINK HK_Pkt XBEESENTBYTECTR", :CONVERTED)
    
    # expect no rejected commands from this sequence
    if( post_cmd_rej != pre_cmd_rej )
      raise "CmdRejCtr incrememented incorrectly!  Expected 0 but got #{post_cmd_rej.to_i-pre_cmd_rej.to_i}"
    end
    # expect 2 executed commands (the first REQ_HK and the NOOP)
    if( post_cmd_exe != pre_cmd_exe + 2 )
      raise "CmdExeCtr incrememented incorrectly! Expected 2 but got #{post_cmd_exe.to_i-pre_cmd_exe.to_i}"
    end
    # expect 18 bytes to have been received (the NoOp and REQ_HK)
    if( post_cmd_rdio_rcvd != pre_cmd_rdio_rcvd + 17 )
      raise "RadioRcvdByteCtr incrememented incorrectly! Expected 17 but got #{post_cmd_rdio_rcvd.to_i-pre_cmd_rdio_rcvd.to_i}"
    end
    # expect 36 bytes to have been sent (1 HK packet)
    if( post_cmd_rdio_sent != pre_cmd_rdio_sent + 36 )
      raise "RadioSentByteCtr incrememented incorrectly! Expected 36 but got #{post_cmd_rdio_sent.to_i-pre_cmd_rdio_sent.to_i}"
    end
    # expect 0 bytes to have been sent via xbee
    if( post_cmd_xbee_rcvd != pre_cmd_xbee_rcvd)
      raise "XbeeRcvdByteCtr incrememented incorrectly! Expected 0 but got #{post_cmd_xbee_rcvd.to_i-pre_cmd_xbee_rcvd.to_i}"
    end
    # expect 0 bytes to have been sent via xbee
    if( post_cmd_xbee_sent != pre_cmd_xbee_sent)
      raise "XbeeSentByteCtr incrememented incorrectly! Expected 0 but got #{post_cmd_xbee_sent.to_i-pre_cmd_xbee_sent.to_i}"
    end
    
  end
  
  def test_04_reqenv_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_ENV command works source: radio"
    
    # request the ENV data
    cmd("LINK", "REQ_ENV")
    
    # wait for the packet to be received
    wait_check_packet("LINK", "ENV_STAT", 1, 5)

    # we can't really check any of the values in the packet because we
    # don't know exactly what they will be. We could check them roughly,
    # but there are limits on those telemetry points which will alert the 
    # user if they have wierd values
    
  end
  
  def test_05_reqfltr_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_FLTR command works source: radio"
    # we need to do this before we can verify the SetFltr command
    # works
    
    # request the filter table values
    cmd("LINK", "REQ_FLTR")

    # wait for the packet to be received
    wait_check_packet("LINK", "FLTRTBL", 1, 5)

    # we can't check the return values because we don't know what 
    # they should be (it depends on what's currently loaded in the
    # table). The values returned will be checked during the SetFltr
    # test
  end
  
  def test_06_reqimu_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_IMU command works source: radio"
    
    # request IMU data
    cmd("LINK", "REQ_IMU")
    
    # wait for the packet to be received
    wait_check_packet("LINK", "IMU_STAT", 1, 5)
    
    # we can't really check any of the values in the packet because we
    # don't know exactly what they will be. We could check them roughly,
    # but there are limits on those telemetry points which will alert the 
    # user if they have wierd values
  end
  
  def test_07_reqinit_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_INIT command works source: radio"
    
    # request and init status packet
    cmd("LINK", "REQ_INIT")
    
    # wait for the packet to be received
    wait_check_packet("LINK", "INIT_STAT", 1, 5)
    
    # we could check the returned values to make sure it initalized correctly.
    # we don't currently because wether or not the hardware initialized is not
    # really relevant to if the command is working
  end
  
  def test_08_reqpwr_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the REQ_PWR command works source: radio"
    
    # request power data
    cmd("LINK", "REQ_PWR")

    # wait for the packet to be received
    wait_check_packet("LINK", "PWR_STAT", 1, 5)
  end
   
  def test_09_fwdmsg_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_FWDMSG command works source: radio"
    # for this test we essentially do a loopback test... sending a packet to Link for
    # it to forward to the ground
    # FIXME: For completeness we should also have a test which sends a packet to an xbee
    # to make sure the logic for that is working
        
    # send a message to be forwarded to the ground which looks like an HK packet 
    # (with fake values that we can easily verify)
    cmd("LINK", "FWD_MSG", "Payload" => "\x08\xD2\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

    # wait for the packet to be received
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
    # verify that we received the packet with the fake values
    check("LINK HK_Pkt CMDREJCTR == 99")
    check("LINK HK_Pkt CMDEXECTR == 99")
    check("LINK HK_Pkt RADIORCVDBYTECTR == 99")
    check("LINK HK_Pkt RADIOSENTBYTECTR == 99")
    check("LINK HK_Pkt XBEERCVDBYTECTR == 99")
    check("LINK HK_Pkt XBEESENTBYTECTR == 99")
  end
  
  def test_10_setfltrtblidx_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"

    # request updated values
    cmd("LINK", "REQ_FLTR")
    
    # wait to receive the packet
    wait_check_packet("LINK", "FLTRTBL", 1, 5)
    
    # store values currently in table so that we can restore them after
    fltr_vals = tlm_variable("LINK FLTRTBL APIDS", :CONVERTED)
    
    # generate random values to upload to the table
    test_fltr_vals = 15.times.map{ Random.rand(100) }
    
    # upload the new values
    for i in 0..14
      cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => i, "FLTR_VAL" => test_fltr_vals[i]) 
      wait(0.2)
    end
    
    # request updated values be sent back to us
    cmd("LINK", "REQ_FLTR")
    
    # wait for the response
    wait_check_packet("LINK", "FLTRTBL", 1, 5)
    
    # extract the values we received into a local variable for checking
    onboard_fltr_vals = tlm_variable("LINK FLTRTBL APIDS", :CONVERTED)

    # loop through and make sure each value is what we sent
    for i in 0..14
      if(onboard_fltr_vals[i] != test_fltr_vals[i])
        raise "Onboard filter value at idx #{i.to_i} did not match expected"
      end
    end
    
    # restore the original values
    for i in 0..14
      cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => i, "FLTR_VAL" => fltr_vals[i]) 
      wait(0.2)
    end
    
    # request the restored values
    cmd("LINK", "REQ_FLTR")
    
    wait_check_packet("LINK", "FLTRTBL", 1, 5)

  end
  
  def test_11_reqtime_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"
          
    # request the payload's time
    cmd("LINK", "REQ_TIME")

    # wait for the response
    wait_check_packet("LINK", "TIME_MSG", 1, 5)

    # we can't really check the value returned because we don't know 
    # what the payload was set to. The returned value is checked as part
    # of the SetTime test
  end
  
  def test_12_settime_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"

    # request the current time    
    cmd("LINK", "REQ_TIME")
    
    # wait for the response
    wait_check_packet("LINK", "TIME_MSG", 1, 5)
    
    # get the time returned in a local variable
    time_pre = tlm_variable("LINK TIME_MSG TIME", :CONVERTED)
    
    # set a time 100sec in the past of what it sent back
    cmd("LINK", "SET_TIME", "TIME" => time_pre.to_i - 100)
    
    # give it a little bit to be executed
    wait(0.1)
    
    # request the new time
    cmd("LINK", "REQ_TIME")
    
    # wait for the packet the be received
    wait_check_packet("LINK", "TIME_MSG", 1, 5)
    
    # get the time returned
    time_post = tlm_variable("LINK TIME_MSG TIME", :CONVERTED)
    
    # check if the new time is less than the old time (ie, the SET_TIME cmd set it to the past)
    if(time_post >= time_pre)
      raise "Pre: #{time_pre.to_i}, Post #{time_post.to_i}. Time not set correctly!"
    end
    
    # FIXME: should we restore the original value?

  end
  
  def test_13_req_fileinfo_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"
      
    # note, this command doesn't always return a packet (if the file idx
    # requested isn't actually a file on the SD card).
    # FIXME: should we revamp this command so that we know if we don't get 
    # a response back?
    cmd("LINK", "REQ_FILEINFO", "FILE_IDX" => 2)
    
    # wait for the response to be received
    wait_check_packet("LINK", "FILEINFO_MSG", 1, 5)

  end
  
  def test_14_req_filepart_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"
      
    # note, this command doesn't always return a packet (if the file idx
    # requested isn't actually a file)
    cmd("LINK", "REQ_FILEPART", "FILE_IDX" => 2, "START_BYTE" => 0, "END_BYTE" => 10)
    
    # wait for the response to be received
    wait_check_packet("LINK", "FILEPART_MSG", 1, 5)

  end
  
  def test_15_reset_ctr_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the RESET_CTR command works source: radio"

    # send the Reset_Ctr command
    cmd("LINK", "RESET_CTR")
    
    # give it a bit to be executed
    wait(0.1)
    
    # request telemetry to verify the counters were reset
    cmd("LINK", "REQ_HK")
    
    # wait for the packet to the received
    wait_check_packet("LINK", "HK_Pkt", 1, 5)
    
    # check the counter values... CMDEXECTR should be 1 because the 
    # RESETCTR command was executed and RADIORCVDBYTECTR should be 9
    # because of the HK_Pkt
    check("LINK HK_Pkt CMDREJCTR == 0")
    check("LINK HK_Pkt CMDEXECTR == 1")
    check("LINK HK_Pkt RADIORCVDBYTECTR == 9")
    check("LINK HK_Pkt RADIOSENTBYTECTR == 0")
    check("LINK HK_Pkt XBEERCVDBYTECTR == 0")
    check("LINK HK_Pkt XBEESENTBYTECTR == 0")

  end
  
  def test_16_req_name_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the ReqName command works source: radio"

    # request the payload send its name
    cmd("LINK", "REQ_NAME")
    
    # wait for the packet to be received
    wait_check_packet("LINK", "NAME_MSG", 1, 5)
    
    # verify it says its link
    if(tlm_variable("LINK NAME_MSG NAME", :RAW) != "    LINK")
      raise "Does not match!"
    end

  end
  
  # Teardown the test case by doing other stuff
  #def teardown
  #  puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  #  wait(2)
  #end

  def helper_method

  end
end

class CmdViaXbeeTest < Cosmos::Test
  def initialize
    super()
  end
  
  # Setup the test case by doing stuff
  def setup
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"

    # set the MY address
    cmd("XBEE", "ATSETCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "MY", "VAL" => 3)
    # request the MY parameter
    cmd("XBEE", "ATCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "MY")
    # verify it was set correctly
    wait_check("XBEE ATCMDRESP RESPONSE == 3", 0.5)

    # set the ID
    cmd("XBEE", "ATSETCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "ID", "VAL" => 2827)
    # request the ID parameter
    cmd("XBEE", "ATCMD", "STARTDELIM" => 126, "PKTLEN" => 4, "FRAMETYPE" => 8, "FRAMEID" => 1, "CMDCODE" => "ID")
    # verify it was set correctly
    wait_check("XBEE ATCMDRESP RESPONSE == 2827", 0.5)
  end
  
  def test_1_resetctr_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the RESETCTR command works"
    
    # send a RESETCTR via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x1E\x00")

    # request an HK packet to check reset
    cmd("LINK", "GND_HK_REQ")
    wait_check("LINK HK_Pkt CMDREJCTR == 0", 0.5)
    wait_check("LINK HK_Pkt CMDEXECTR == 1", 0.5)
    wait_check("LINK HK_Pkt RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK HK_Pkt RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK HK_Pkt XBEERCVDBYTECTR == 0", 0.5)
    wait_check("LINK HK_Pkt XBEESENTBYTECTR == 0", 0.5)
  end
  
  
  def test_2_noop_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works"
    
    # send NoOp message via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x00\x00")

    # send GND_HK_REQ message via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x0A\x00")

    # verify the telemetry updates
    wait_check("LINK HK_Pkt CMDREJCTR == 0", 0.5)
    wait_check("LINK HK_Pkt CMDEXECTR == 3", 0.5)
    wait_check("LINK HK_Pkt RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK HK_Pkt RADIOSENTBYTECTR == 36", 0.5)
    wait_check("LINK HK_Pkt XBEERCVDBYTECTR == 16", 0.5)
    wait_check("LINK HK_Pkt XBEESENTBYTECTR == 0", 0.5)
  end

  def test_3_gnd_fwdmsg_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_FWDMSG command works"
    
    # message to be forwarded to the ground is structured as an HK message with fake values
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x0F\x00\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

    # verify the telemetry updates
    wait_check("LINK HK_Pkt CMDREJCTR == 99", 0.5)
    wait_check("LINK HK_Pkt CMDEXECTR == 99", 0.5)
    wait_check("LINK HK_Pkt RADIORCVDBYTECTR == 99", 0.5)
    wait_check("LINK HK_Pkt RADIOSENTBYTECTR == 99", 0.5)
    wait_check("LINK HK_Pkt XBEERCVDBYTECTR == 99", 0.5)
    wait_check("LINK HK_Pkt XBEESENTBYTECTR == 99", 0.5)
  end

  def test_4_xb_fwdmsg_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the XB_FWDMSG command works"
    
    # send a XB_FWDMSG via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x06\x19\x00\x02\x48\x65\x6C\x6C\x6F")

    # verify the telemetry updates
    resp = message_box("Did we receive an unknown 5 byte packet on the link interface with the value 48656C6C6F?","Yes","No")

    if(resp != 'Yes')
      raise "Didn't receive packet!"
    end
    
  end
  
  def test_5_xb_hk_req_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the XB_HK_REQ command works"
    
    # send a XB_HK_REQ via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x14\x00")

    # verify the telemetry updates
    resp = message_box("Did we receive an unknown 32 byte packet on the link interface that starts with the value 086E?","Yes","No")

    if(resp != 'Yes')
      raise "Didn't receive packet!"
    end
  end
  
  def test_6_gnd_hk_req_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the XB_HK_REQ command works"
            
            
    cmd("LINK", "RESETCTR")

    # send a XB_HK_REQ via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x0A\x00")
    
    # verify the telemetry updates
    wait_check("LINK HK_Pkt CMDREJCTR == 0", 0.5)
    wait_check("LINK HK_Pkt CMDEXECTR == 1", 0.5)
    wait_check("LINK HK_Pkt RADIORCVDBYTECTR == 0", 0.5)
    wait_check("LINK HK_Pkt RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK HK_Pkt XBEERCVDBYTECTR == 8", 0.5)
    wait_check("LINK HK_Pkt XBEESENTBYTECTR == 0", 0.5)
    
  end
  
  def test_7_tlmfltrtbl_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the TLMFLTRTBL command works"
    
    # send a TLMFLTRTBL via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x28\x00")

    # verify the telemetry updates
    # check that the values are the values after the last command
    wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 10, 0, 0, 0]", 0.5)
  end
  
  def test_8_setfltrtblidx_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works"
    
   # send a SETFLTRTBLIDX via the xbee
   cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x2D\x00\x06\x00\x00")

   # request telemetry of current values
   cmd("LINK", "TLMFLTRTBL")

   # check that the values are have changed
   wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 0, 0, 0, 0]", 0.5)

  end
  def teardown
  
    # reboot link to reset it
    cmd_no_hazardous_check("LINK", "REBOOT")
  end
  def helper_method

  end
end

class FunctionalTest < Cosmos::Test
  def initialize
    super()
  end
    
  def test_1_filter_table
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the filter forwarding works"
    
    # send a raw packet with a APID not in the table: 255
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\xFF\xC0\x00\x00\x04\x1E\x00")

    # verify that the ground received no packets
    resp = message_box("Did we receive an unknown 8 byte packet on the link interface that starts with the value 10FF?", "Yes","No")
    if(resp != 'No')
      raise "Received pkt and shouldn't have"
    end
    
    # update the filter table to include the APID
    cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => 6, "FLTR_VAL" => 255)

    # send a raw packet with an APID now in the table: 255
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\xFF\xC0\x00\x00\x04\x1E\x00")

    # verify that the ground received the packet
    resp = message_box("Did we receive an unknown 8 byte packet on the link interface that starts with the value 10FF?", "Yes","No")

    if(resp != 'Yes')
      raise "Didn't receive pkt"
    end
    
  end

  def helper_method

  end
end
  
# This is an ExampleTestSuite which only runs ExampleTest
class LinkTestSuite < Cosmos::TestSuite
  def initialize
    super()
    add_test('CmdViaRadioTest')
    add_test('CmdViaXbeeTest')
    add_test('FunctionalTest')
  end
end