load 'cosmos/tools/test_runner/test.rb'

# This Test demonstrates the usage of the setup and teardown methods
# as well as defining two tests. Notice that the setup and teardown
# methods must be called exactly that. Other test methods must start
# with 'test_' to be picked up by TestRunner.
class CmdTest < Cosmos::Test
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
   
  end
  
  def test_1_hk_req_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_HK_REQ command works source: radio"
    
    # request telemetry to verify counters were reset
    cmd("SCORCH", "CMD", "FCNCODE" => "HK_REQ")
    wait_check("SCORCH HK_STATUS CMDREJCTR == 0", 0.5)
    wait_check("SCORCH HK_STATUS CMDEXECTR == 0", 0.5)
    wait_check("SCORCH HK_STATUS XBEERCVDBYTECTR == 8", 0.5)
    wait_check("SCORCH HK_STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_2_noop_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NOP command works source: radio"
    
    cmd("SCORCH", "CMD", "FCNCODE" => "NOOP")
    
    # request telemetry to verify NoOp cmd
    cmd("SCORCH", "CMD", "FCNCODE" => "HK_REQ")
    wait_check("SCORCH HK_STATUS CMDREJCTR == 0", 0.5)
    wait_check("SCORCH HK_STATUS CMDEXECTR == 3", 0.5)
    wait_check("SCORCH HK_STATUS XBEERCVDBYTECTR == 24", 0.5)
    wait_check("SCORCH HK_STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_3_resetctr_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_HK_REQ command works source: radio"
    
    cmd("SCORCH", "CMD", "FCNCODE" => "RESETCTR")
    
    # request telemetry to verify counters were reset
    cmd("SCORCH", "CMD", "FCNCODE" => "HK_REQ")
    wait_check("SCORCH HK_STATUS CMDREJCTR == 0", 0.5)
    wait_check("SCORCH HK_STATUS CMDEXECTR == 0", 0.5)
    wait_check("SCORCH HK_STATUS XBEERCVDBYTECTR == 8", 0.5)
    wait_check("SCORCH HK_STATUS XBEESENTBYTECTR == 0", 0.5)
  end
  
  def test_4_status_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NOP command works source: radio"
    
    # check that the last status packet (from when SCORCH initalized)
    # indicates that the status is initalized
    wait_check("SCORCH STATUS STATUS == INITALIZED", 0.5)
    
    # request a new status
    cmd("SCORCH", "CMD", "FCNCODE" => "STATUS")
    
    # check that scorch reports disarmed
    wait_check("SCORCH STATUS STATUS == UNARMED", 0.5)
    
  end
  
  def test_5_arm_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NOP command works source: radio"
    
    # request a new status
    cmd("SCORCH", "CMD", "FCNCODE" => "STATUS")
    
    # check that SCORCH is currently disarmed
    wait_check("SCORCH STATUS STATUS == DISARMED", 0.5)
    
    # arm scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "ARM")    
    
    wait(0.5)
        
    # check that scorch reports armed
    wait_check("SCORCH STATUS STATUS == ARMED", 0.5)
    
  end
  
  def test_6_disarm_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NOP command works source: radio"
    
    # request a new status
    cmd("SCORCH", "CMD", "FCNCODE" => "STATUS")
    
    # check that SCORCH is currently armed
    wait_check("SCORCH STATUS STATUS == ARMED", 0.5)
    
    # disarm scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "DISARM")
    
    wait(0.5)
    
    # check that scorch reports disarmed
    wait_check("SCORCH STATUS STATUS == DISARMED", 0.5)
    
  end
  
  def test_7_fire_cmd
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the NOP command works source: radio"
    
    # request a new status
    cmd("SCORCH", "CMD", "FCNCODE" => "STATUS")
    
    # check that SCORCH is currently disarmed
    wait_check("SCORCH STATUS STATUS == DISARMED", 0.5)
    
    # fire scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "FIRE")
    
    wait(0.5)
    
    # check that scorch didn't report a firing (since it was disarmed)
    wait_check("SCORCH STATUS STATUS == DISARMED", 0.5)
    
    # arm scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "ARM")
    
    # fire scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "FIRE")
    
    # check that SCORCH says it fired
    wait_check("SCORCH STATUS STATUS == FIRED", 0.5)
    
    wait(0.5)
    
    # check that SCORCH disarmed itself
    wait_check("SCORCH STATUS STATUS == DISARMED", 0.5)
    
  end
  
  def helper_method

  end
end
  
class FunctionalTest < Cosmos::Test
  def initialize
    super()
  end

  
  def test_1_arm_timeout
    puts "Running #{Cosmos::Test.current_test_suite}:#{Cosmos::Test.current_test}:#{Cosmos::Test.current_test_case}"
    Cosmos::Test.puts "This test verifies requirement that the GND_HK_REQ command works source: radio"
    
    # arm scorch
    cmd("SCORCH", "CMD", "FCNCODE" => "ARM")
    
    # check that SCORCH armed itself
    wait_check("SCORCH STATUS STATUS == ARMED", 0.5)
    
    # check that SCORCH disarmed itself after the timeout
    wait_check("SCORCH STATUS STATUS == ARMED", 60)
  end
  
  def helper_method

  end
end
  
# This is an ExampleTestSuite which only runs ExampleTest
class ScorchTestSuite < Cosmos::TestSuite
  def initialize
    super()
    add_test('CmdTest')
    add_test('FunctionalTest')
  end
end