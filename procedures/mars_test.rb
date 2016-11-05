load 'cosmos/tools/test_runner/test.rb'

# This Test demonstrates the usage of the setup and teardown methods
# as well as defining two tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class MARSTest < Cosmos::Test
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
  
  def test_1_reboot_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies that on startup the counters are zeroed."
        
    # reboot Link
    cmd_no_hazardous_check("MARS", "REBOOT")
    wait(5)
    
    # request telemetry to verify NoOp cmd
    cmd("MARS", "REQ_HK", "DESTINATION" => 0)
    wait_check("MARS HK_Pkt CMDREJCTR == 0", 0.5)
    wait_check("MARS HK_Pkt CMDEXECTR == 0", 0.5)
    wait_check("MARS HK_Pkt RADIORCVDBYTECTR == 9", 0.5)
    wait_check("MARS HK_Pkt RADIOSENTBYTECTR == 0", 0.5)
    wait_check("MARS HK_Pkt XBEERCVDBYTECTR == 0", 0.5)
    wait_check("MARS HK_Pkt XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_2_noop_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command results in a command execution and that the REQ_HK command returns HK telemetry source: radio"
    
    # issue a NoOp cmd
    cmd("MARS", "NOOP")
    wait(0.1)

    # request telemetry to verify NoOp cmd
    cmd("MARS", "REQ_HK")
    wait_check("MARS HK_Pkt CMDREJCTR == 0", 0.5)
    wait_check("MARS HK_Pkt CMDEXECTR == 2", 0.5)
    wait_check("MARS HK_Pkt RADIORCVDBYTECTR == 26", 0.5)
    wait_check("MARS HK_Pkt RADIOSENTBYTECTR == 36", 0.5)
    wait_check("MARS HK_Pkt XBEERCVDBYTECTR == 0", 0.5)
    wait_check("MARS HK_Pkt XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_3_reqenv_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works source: radio"
    
    env_rcvd_cnt_pre = tlm_variable("MARS ENV_STAT RECEIVED_COUNT", :CONVERTED)

    # issue a NoOp cmd
    cmd("MARS", "REQ_ENV")
    wait(0.5)

    env_rcvd_cnt_post = tlm_variable("MARS ENV_STAT RECEIVED_COUNT", :CONVERTED)

    # check if we received one
    if(env_rcvd_cnt_post == env_rcvd_cnt_pre)
      raise "Pre: #{env_rcvd_cnt_pre.to_i}, Post #{env_rcvd_cnt_post.to_i}. Didn't receive packet!"
    end
  end
  
  def test_4_reqimu_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works source: radio"
    
    imu_rcvd_cnt_pre = tlm_variable("MARS IMU_STAT RECEIVED_COUNT", :CONVERTED)

    # issue a NoOp cmd
    cmd("MARS", "REQ_IMU")
    wait(0.5)

    imu_rcvd_cnt_post = tlm_variable("MARS IMU_STAT RECEIVED_COUNT", :CONVERTED)

    # check if we received one
    if(imu_rcvd_cnt_post == imu_rcvd_cnt_pre)
      raise "Pre: #{imu_rcvd_cnt_pre.to_i}, Post #{imu_rcvd_cnt_post.to_i}. Didn't receive packet!"
    end
  end
  
  def test_5_reqinit_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works source: radio"
    
    init_rcvd_cnt_pre = tlm_variable("MARS INIT_STAT RECEIVED_COUNT", :CONVERTED)

    # issue a NoOp cmd
    cmd("MARS", "REQ_INIT")
    wait(0.5)

    init_rcvd_cnt_post = tlm_variable("MARS INIT_STAT RECEIVED_COUNT", :CONVERTED)

    # check if we received one
    if(init_rcvd_cnt_post == init_rcvd_cnt_pre)
      raise "Pre: #{init_rcvd_cnt_pre.to_i}, Post #{init_rcvd_cnt_post.to_i}. Didn't receive packet!"
    end
  end
  
  def test_6_reqpwr_radio
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NoOp command works source: radio"
    
    pwr_rcvd_cnt_pre = tlm_variable("MARS PWR_STAT RECEIVED_COUNT", :CONVERTED)

    # issue a NoOp cmd
    cmd("MARS", "REQ_PWR")
    wait(0.5)

    pwr_rcvd_cnt_post = tlm_variable("MARS PWR_STAT RECEIVED_COUNT", :CONVERTED)

    # check if we received one
    if(pwr_rcvd_cnt_post == pwr_rcvd_cnt_pre)
      raise "Pre: #{pwr_rcvd_cnt_pre.to_i}, Post #{pwr_rcvd_cnt_post.to_i}. Didn't receive packet!"
    end
  end
   
   
  def test_7_extend
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"

    cmd("MARS", "EXTEND", "DESTINATION" => 2)
    wait(0.5)
      
    # check that the values changed
    wait_check("LINK STATS STATUS == EXTENDED", 0.5)

  end
  
  def test_7_retract
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the SETFLTRTBLIDX command works source: radio"

    cmd("MARS", "RETRACT", "DESTINATION" => 2)
    wait(0.5)
      
    wait_check("LINK STATS STATUS == RETRACTED", 0.5)
  end
  
  # Teardown the test case by doing other stuff
  #def teardown
  #  puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
  #  wait(2)
  #end

  def helper_method

  end
end

  
# This is an ExampleTestSuite which only runs ExampleTest
class MarsTestSuite < Cosmos::TestSuite
  def initialize
    super()
    add_test('MARSTest')
  end
end