
########### test setup ################
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
puts("Verifying: counters initialzed correctly")
# request telemetry to check that counters initalized
# to zero
cmd("LINK", "GND_HK_REQ")
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 0", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)

puts("Completed: counters initialzed correctly")

########### cmd check: NoOp and GND_HK_REQ, source: radio ###########
puts("Verifying: NoOp and GND_HK_REQ cmds, Source: radio")

# issue a NoOp cmd
cmd("LINK", "NOOP")
wait(0.1)

# request telemetry to verify NoOp cmd
cmd("LINK", "GND_HK_REQ")
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 2", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 24", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 36", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)

puts("Completed: NoOp and GND_HK_REQ cmds, Source: radio")

########### cmd check: Gnd_Fwd_Msg, source: radio #####
puts("Verifying: Gnd_Fwd_Msg cmd, Source: radio")

wait(0.5)
cmd("LINK", "GND_FWDMSG", "Payload" => "\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

puts("Completed: Gnd_Fwd_Msg cmd, Source: radio")

########### cmd check: XB_FWDMSG, source: radio #####
puts("Verifying: XB_FWDMSG cmd, Source: radio")

cmd("LINK", "XB_FWDMSG", "DESTINATION" => 3, "PAYLOAD" => "\x7E\x00\x11\x80\x00\x00\x00\x00\x00\x00\x00\x02\x00\x01\x01\x02\x03\x04\x05\x06\x67")

#wait_check("XBEE RX64MSG DATA == \x01\x02\x03\x04\x05\x06", 0.5)

puts("Completed: XB_FWDMSG cmd, Source: radio")

########### cmd check: XB_HK_REQ, source: radio #####
puts("Verifying: XB_HK_REQ cmd, Source: radio")

cmd("LINK", "XB_HK_REQ", "DESTINATION" => 3)
wait(0.5)

cmd("LINK", "GND_HK_REQ")
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 6", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 115", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 108", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 57", 0.5)

puts("Completed: XB_HK_REQ cmd, Source: radio")

########### cmd check: TLMFLTRTBL, source: radio #####
puts("Verifying: TLMFLTRTBL cmd, Source: radio")

cmd("LINK", "TLMFLTRTBL")

# check that the values are the default table
wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 0, 0, 0, 0]", 0.5)

puts("Completed: TLMFLTRTBL cmd, Source: radio")

########### cmd check: SETFLTRTBLIDX, source: radio #####
puts("Verifying: SETFLTRTBLIDX cmd, Source: radio")

cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => 6, "FLTR_VAL" => 10)
wait(0.5)

# request updated values
cmd("LINK", "TLMFLTRTBL")

# check that the values changed
wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 10, 0, 0, 0]", 0.5)

puts("Completed: SETFLTRTBLIDX cmd, Source: radio")

########### cmd check: RESETCTR, source: radio #####
puts("Verifying: RESETCTR cmd, Source: radio")

cmd("LINK", "RESETCTR")

# request an HK packet to check reset
cmd("LINK", "GND_HK_REQ")
wait_check("LINK STATUS CMDREJCTR == 0", 0.5)
wait_check("LINK STATUS CMDEXECTR == 1", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 8", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 0", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 0", 0.5)

puts("Completed: RESETCTR cmd, Source: radio")

########### cmd check: NoOp and GND_HK_REQ, source: xbee #####
puts("Verifying: NoOp and GND_HK_REQ cmd, Source: xbee")

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

puts("Completed: NoOp and RESETCTR cmd, Source: xbee")

########### cmd check: GND_FWDMSG, source: xbee #####
puts("Verifying: GND_FWDMSG cmd, Source: xbee")

# message to be forwarded to the ground is structured as an HK message with fake values
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x0F\x00\x08\x6E\x00\x00\x00\x1D\x00\x00\x00\x17\x02\xD5\x00\x63\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63\x00\x00\x00\x63")

# verify the telemetry updates
wait_check("LINK STATUS CMDREJCTR == 99", 0.5)
wait_check("LINK STATUS CMDEXECTR == 99", 0.5)
wait_check("LINK STATUS RADIORCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS RADIOSENTBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEERCVDBYTECTR == 99", 0.5)
wait_check("LINK STATUS XBEESENTBYTECTR == 99", 0.5)

puts("Completed: GND_FWDMSG cmd, Source: xbee")

########### cmd check: XB_FWDMSG, source: xbee #####
puts("Verifying: XB_FWDMSG cmd, Source: xbee")

# send a XB_FWDMSG via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x06\x19\x00\x02\x48\x65\x6C\x6C\x6F")

# verify the telemetry updates
resp = ask("Did we receive an unknown 5 byte packet on the link interface with the value 48656C6C6F?")

puts("Completed: XB_FWDMSG cmd, Source: xbee")

########### cmd check: XB_HK_REQ, source: xbee #####
puts("Verifying: XB_HK_REQ cmd, Source: xbee")

# send a XB_HK_REQ via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x14\x00")

# verify the telemetry updates
resp = ask("Did we receive an unknown 32 byte packet on the link interface that starts with the value 086E?")

puts("Completed: XB_HK_REQ cmd, Source: xbee")

########### cmd check: TLMFLTRTBL, source: xbee #####
puts("Verifying: TLMFLTRTBL cmd, Source: xbee")

# send a TLMFLTRTBL via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x28\x00")

# verify the telemetry updates
# check that the values are the values after the last command
wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 10, 0, 0, 0]", 0.5)

puts("Completed: TLMFLTRTBL cmd, Source: xbee")

########### cmd check: SETFLTRTBLIDX, source: xbee #####
puts("Verifying: SETFLTRTBLIDX cmd, Source: xbee")

# send a SETFLTRTBLIDX via the xbee
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\x64\xC0\x00\x00\x04\x2D\x00\x06\x00\x00")

# request telemetry of current values
cmd("LINK", "TLMFLTRTBL")

# check that the values are have changed
wait_check("LINK FLTRTBL APIDS == [200, 210, 220, 300, 310, 320, 0, 0, 0, 0]", 0.5)

puts("Completed: SETFLTRTBLIDX cmd, Source: xbee")

########### cmd check: RESETCTR, source: xbee #####
puts("Verifying: RESETCTR cmd, Source: xbee")

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

puts("Completed: RESETCTR cmd, Source: xbee")

########### functional check: filter table forwarding #####
puts("Verifying: Filter table forwarding")

# send a raw packet with a APID not in the table: 255
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\xFF\xC0\x00\x00\x04\x1E\x00")

# verify that the ground received no packets
resp = ask("Did we receive an unknown 8 byte packet on the link interface that starts with the value 10FF?")

# update the filter table to include the APID
cmd("LINK", "SETFLTRTBLIDX", "FLTR_IDX" => 6, "FLTR_VAL" => 255)

# send a raw packet with an APID now in the table: 255
cmd("XBEE", "TX64MSG", "ADDR" => 2, "OPTIONS" => 0, "DATA" => "\x10\xFF\xC0\x00\x00\x04\x1E\x00")

# verify that the ground received the packet
resp = ask("Did we receive an unknown 8 byte packet on the link interface that starts with the value 10FF?")


puts("Completed: Filter table forwarding")

puts("LINK test suite passed!")