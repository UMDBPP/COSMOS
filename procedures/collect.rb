load_utility 'collect_util.rb'
load_utility 'clear_util.rb'

number = ask("Enter a number.")
raise "Bad return" unless number.is_a? Numeric
number = ask_string("Enter a number.")
raise "Bad return" unless number.is_a? String

result = message_box("Click something.", "BLAH", "WHAT")
raise "Bad return" unless result == 'BLAH' or result == 'WHAT'

prompt("Press Ok to start NORMAL Collect")
collect('NORMAL', 1)
prompt("Press Ok to start SPECIAL Collect")
collect('SPECIAL', 2, true)
clear()

wait_check("INST HEALTH_STATUS COLLECTS == 0", 10)
