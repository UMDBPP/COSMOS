
########### test setup ################
# if interfaces are not connected, try to connect
disconnect_interface("XBEE_INT")
wait(1)
connect_interface("XBEE_INT")

disconnect_interface("LINKCCSDS_INT")
wait(1)
connect_interface("LINKCCSDS_INT")

########## have the user reset Link
string = ask_string("Please reset LINK. Enter anything to continue.")
wait(5)


########## Configure Xbee #########
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

########## command verifications ##

########## verify initial state #######
# request telemetry to check that counters initalized
# to zero
cmd("LINK", "GND_HK_REQ", "FCNCODE" => 10)
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 0", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)

########### cmd check: NoOp ###########
# issue a NoOp cmd
cmd("LINK", "NOOP")
wait(0.1)

# request telemetry to verify NoOp cmd
cmd("LINK", "GND_HK_REQ", "FCNCODE" => 10)
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 2", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 24", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 36", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)

########### cmd check: Gnd_Fwd_Msg #####
wait(0.5)
cmd("LINK", "GND_FWDMSG", "FCNCODE" => 15, "Payload" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

########### cmd check: XB_FWDMSG #####
cmd("LINK", "XB_FWDMSG", "FCNCODE" => 25, "DESTINATION" => 3, "PAYLOAD" => "\x7E\x00\x11\x80\x00\x00\x00\x00\x00\x00\x00\x02\x00\x01\x01\x02\x03\x04\x05\x06\x67")

#wait_check("XBEE RX64MSG DATA == \x01\x02\x03\x04\x05\x06", 0.5)

########### cmd check: XB_HK_REQ #####
cmd("LINK", "XB_HK_REQ", "FCNCODE" => 20, "DESTINATION" => 3)
wait(0.5)

cmd("LINK", "GND_HK_REQ", "FCNCODE" => 10)
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 6", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 115", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 108", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 57", 0.5)

######### test LINK receiving a command via xbee
# send GND_HK_REQ message via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x00\x00")

# send GND_HK_REQ message via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x01\x0A\x00")

# verify the telemetry updates
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 8", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 115", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 144", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 16", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 57", 0.5)

# send GND_FWDMSG message via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

# verify the telemetry updates
wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

# send XB_FWSMSG message via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

# verify the telemetry updates
wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

# send XB_HK_REQ message via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

# verify the telemetry updates
wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

puts("LINK test suite passed!")