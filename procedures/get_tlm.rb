
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
   for ii in 0..5
      puts("sleep #{ii} sec" )
      sleep(1)  
   end
end