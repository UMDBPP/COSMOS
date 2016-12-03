
for i in 0..100
   
   cmd("LINK REQ_HK")
   sleep(0.25)
   cmd("LINK REQ_ENV")
   sleep(0.25)
   cmd("LINK REQ_PWR")
   sleep(0.25)
   cmd("LINK REQ_IMU")
   sleep(0.25)
   cmd("LINK REQ_FLTR")
   sleep(0.25)
   cmd("LINK REQ_INIT")
   sleep(0.25)
   connect_interface("RFD900_INT")
   cmd("RFD900", "ATMODE")
   wait(1.2)
   cmd("RFD900", "REQ_RSSI_RPT")
   wait(0.1)
   cmd("RFD900", "NORMAL_MODE")
   disconnect_interface("LINKCCSDS_INT")
   connect_interface("LINKCCSDS_INT")
   for ii in 0..5
      puts("sleep #{ii} sec" )
      sleep(1)  
   end
end