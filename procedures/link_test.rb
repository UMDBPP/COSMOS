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
    disconnect_interface("XBEE_INT")
    wait(1)
    connect_interface("XBEE_INT")

    disconnect_interface("LINKCCSDS_INT")
    wait(1)
    connect_interface("LINKCCSDS_INT")
    
    ########## have the user reset Link
    message_box("Please reset LINK.", "Continue")
    puts("Waiting for LINK to initalize...")
    wait(2)
    
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
  
  def test_1_resetctr_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_HK_REQ command works source: radio"
    
    cmd("LINK", "RESETCTR")
    
    # request telemetry to verify NoOp cmd
    cmd("LINK", "GND_HK_REQ")
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 1", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_2_noop_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works source: radio"
    
    cmd("LINK", "RESETCTR")
    # issue a NoOp cmd
    cmd("LINK", "NOOP")
    wait(0.1)

    # request telemetry to verify NoOp cmd
    cmd("LINK", "GND_HK_REQ")
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 2", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 16", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
  end
   
  def test_3_gnd_fwdmsg_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_FWDMSG command works source: radio"
        
    # send a message to be forwarded to the ground which looks like an HK packet 
    # (with fake values that we can easily verify)
    cmd("LINK", "GND_FWDMSG", "Payload" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

    # verify that we received the packet with the fake values
    wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)
  end
  
  def test_4_xb_fwdmsg_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the XB_FWDMSG command works source: radio"
    
    # send a command to forward a message to the xbee
    #cmd("LINK", "XB_FWDMSG", "DESTINATION" => 3, "PAYLOAD" => "\x7E\x00\x11\x80\x00\x00\x00\x00\x00\x00\x00\x02\x00\x01\x01\x02\x03\x04\x05\x06\x67")
    cmd("LINK", "XB_FWDMSG", "DESTINATION" => 3, "PAYLOAD" => "x01\x02\x03\x04\x05\x06")

  end
  
  def test_5_xb_hk_req_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the XB_HK_REQ command works source: radio"
    
      cmd("LINK", "XB_HK_REQ", "DESTINATION" => 3)
      wait(0.5)

      #cmd("LINK", "GND_HK_REQ")
      
      # temporarily map LINK to the xbee interface so that the HK packet is interpreted
      #map_target_to_interface("LINK", "XBEE_INT")
      wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
      wait_check("LINK STATUS CMDEXECTR == 6", 0.5)
      wait_check("LINK STATUS RADIORCVDBYTECTR == 115", 0.5)
      wait_check("LINK STATUS RADIOSENTBYTECTR == 108", 0.5)
      wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
      wait_check("LINK STATUS XBEESENTBYTECTR == 57", 0.5)
      #map_target_to_interface("LINK", "LINKCCSDS_INT")
      
  end
  
  def test_6_gnd_hk_req_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_HK_REQ command works source: radio"
    
    cmd("LINK", "RESETCTR")
    
    cmd("LINK", "GND_HK_REQ")
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 1", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_7_tlmfltrtbl_radio
      puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
      Cosmos::Test.puts "This test verifies requirement that the TLMFLTRTBL command works source: radio"
      
      cmd("LINK", "TLMFLTRTBL")

      # check that the values are the default table
      wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 0, 0, 0, 0]", 0.5)

  
  end
  
  def test_8_setfltrtblidx_radio
      puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
      Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"

      cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => 6, "FLTR_VAL" => 10)
      wait(0.5)
      
      # request updated values
      cmd("LINK", "TLMFLTRTBL")
      
      # check that the values changed
      wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 10, 0, 0, 0]", 0.5)

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
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 1", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  
  def test_2_noop_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works"
    
    # send NoOp message via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x00\x00")

    # send GND_HK_REQ message via the xbee
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x0A\x00")

    # verify the telemetry updates
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 3", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 36", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 16", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
  end

  def test_3_gnd_fwdmsg_xbee
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_FWDMSG command works"
    
    # message to be forwarded to the ground is structured as an HK message with fake values
    cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x0F\x00\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

    # verify the telemetry updates
    wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)
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
    wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
    wait_check("LINK STATUS CMDEXECTR == 1", 0.5)
    wait_check("LINK STATUS RADIORCVDBYTECTR == 0", 0.5)
    wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
    wait_check("LINK STATUS XBEERCVDBYTECTR == 8", 0.5)
    wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)
    
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