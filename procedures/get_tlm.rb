
for i in 0..100
   
   cmd("CAMERA HK_REQ")
   sleep(0.25)
   cmd("CAMERA ENV_STAT_REQ")
   sleep(0.25)
   cmd("CAMERA PWR_STAT_REQ")
   sleep(0.25)
   cmd("CAMERA IMU_STAT_REQ")
   sleep(0.25)
   cmd("LINK HK_REQ")
   sleep(0.25)
   cmd("LINK REQ_ENV")
   sleep(0.25)
   cmd("LINK REQ_PWR")
   sleep(0.25)
   cmd("LINK REQ_IMU")
   sleep(0.25)
   cmd("LINK FLTR_REQ")
   for ii in 0..5
      puts("sleep #{ii} sec" )
      sleep(1)  
   end
end